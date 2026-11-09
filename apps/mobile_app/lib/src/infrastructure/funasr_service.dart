import 'dart:async';
import 'dart:ffi';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

typedef _CreateNative = Pointer<Void> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _CreateDart = Pointer<Void> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _DestroyNative = Void Function(Pointer<Void>);
typedef _DestroyDart = void Function(Pointer<Void>);
typedef _RecognizeNative =
    Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef _RecognizeDart =
    int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, int);

final class LocalSpeechService {
  static const _iosSpeech = MethodChannel('net_keyboard/speech');
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  _AsrWorker? _worker;
  Map<String, String>? _modelHashes;

  Future<void> startRecording() async {
    if (Platform.isIOS) {
      final authorized = await _iosSpeech.invokeMethod<bool>(
        'ensureAuthorized',
      );
      if (authorized != true) {
        throw StateError('没有语音识别权限，请在系统设置中允许语音识别');
      }
    }
    if (!await _recorder.hasPermission()) {
      throw StateError('没有麦克风权限，请在系统设置中允许录音');
    }
    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/net-keyboard-${DateTime.now().microsecondsSinceEpoch}.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 24000,
        numChannels: 1,
      ),
      path: path,
    );
    _recordingPath = path;
  }

  Future<String> stopAndRecognize() async {
    final path = await _recorder.stop() ?? _recordingPath;
    _recordingPath = null;
    if (path == null) throw StateError('没有可识别的录音');
    try {
      final String text;
      if (Platform.isIOS) {
        text =
            await _iosSpeech.invokeMethod<String>('recognizeFile', {
              'path': path,
              'locale': 'zh-CN',
            }) ??
            '';
      } else if (Platform.isAndroid) {
        if (_worker == null) {
          final models = await _prepareModels();
          _worker = await _AsrWorker.start(models.$1, models.$2);
        }
        text = await _worker!.recognize(path);
      } else {
        throw UnsupportedError('当前控制端平台不支持语音识别');
      }
      final trimmed = text.trim();
      if (trimmed.isEmpty) throw StateError('没有识别到语音');
      return trimmed;
    } finally {
      File(path).delete().ignore();
    }
  }

  Future<void> cancel() async {
    final path = _recordingPath;
    _recordingPath = null;
    await _recorder.cancel();
    if (path != null) File(path).delete().ignore();
  }

  Future<(String, String)> _prepareModels() async {
    final hashes = await _loadModelManifest();
    final support = await getApplicationSupportDirectory();
    final model = await _extract(
      'assets/speech/funasr-paraformer-zh/',
      '${support.path}/speech/paraformer',
      hashes,
    );
    final vad = await _extract(
      'assets/speech/funasr-fsmn-vad/',
      '${support.path}/speech/vad',
      hashes,
    );
    return (model.path, vad.path);
  }

  Future<Map<String, String>> _loadModelManifest() async {
    if (_modelHashes case final cached?) return cached;
    final source = await rootBundle.loadString('assets/speech/manifest.json');
    final manifest = jsonDecode(source) as Map<String, Object?>;
    if (manifest['native_android_ready'] != true) {
      throw StateError('当前安装包未集成语音识别原生运行库');
    }
    final raw = (manifest['files'] as Map).cast<String, Object?>();
    final hashes = raw.map((key, value) => MapEntry(key, value! as String));
    if (hashes.isEmpty) throw StateError('FunASR 模型 manifest 为空');
    _modelHashes = hashes;
    return hashes;
  }

  Future<Directory> _extract(
    String prefix,
    String target,
    Map<String, String> hashes,
  ) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().where(
      (asset) => asset.startsWith(prefix),
    );
    if (assets.isEmpty) throw StateError('FunASR 模型未打包，请运行模型准备脚本');
    final directory = Directory(target);
    await directory.create(recursive: true);
    for (final asset in assets) {
      final relative = asset.substring(prefix.length);
      if (relative.isEmpty) continue;
      final manifestKey = asset.substring('assets/speech/'.length);
      final expectedHash = hashes[manifestKey];
      if (expectedHash == null) {
        throw StateError('FunASR 模型 manifest 缺少 $manifestKey');
      }
      final file = File('${directory.path}/$relative');
      final data = await rootBundle.load(asset);
      var valid = false;
      if (await file.exists() && await file.length() == data.lengthInBytes) {
        valid =
            (await sha256.bind(file.openRead()).first).toString() ==
            expectedHash;
      }
      if (!valid) {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
        final actualHash = (await sha256.bind(file.openRead()).first)
            .toString();
        if (actualHash != expectedHash) {
          await file.delete();
          throw StateError('FunASR 模型校验失败：$manifestKey');
        }
      }
    }
    return directory;
  }

  Future<void> dispose() async {
    await cancel();
    await _worker?.dispose();
    _worker = null;
    await _recorder.dispose();
  }
}

final class _AsrWorker {
  _AsrWorker(this._isolate, this._commands);
  final Isolate _isolate;
  final SendPort _commands;

  static Future<_AsrWorker> start(String model, String vad) async {
    final ready = ReceivePort();
    final isolate = await Isolate.spawn(_workerMain, (
      ready.sendPort,
      model,
      vad,
    ));
    final commands = await ready.first as SendPort;
    ready.close();
    return _AsrWorker(isolate, commands);
  }

  Future<String> recognize(String path) async {
    final response = ReceivePort();
    _commands.send(('recognize', path, response.sendPort));
    final value = await response.first;
    response.close();
    if (value is String) return value;
    throw StateError((value as List).join(': '));
  }

  Future<void> dispose() async {
    _commands.send(('dispose', '', null));
    _isolate.kill(priority: Isolate.beforeNextEvent);
  }

  static void _workerMain((SendPort, String, String) bootstrap) {
    final receive = ReceivePort();
    bootstrap.$1.send(receive.sendPort);
    try {
      final library = DynamicLibrary.open('libnet_keyboard_asr.so');
      final create = library.lookupFunction<_CreateNative, _CreateDart>(
        'net_asr_create',
      );
      final destroy = library.lookupFunction<_DestroyNative, _DestroyDart>(
        'net_asr_destroy',
      );
      final recognize = library
          .lookupFunction<_RecognizeNative, _RecognizeDart>(
            'net_asr_recognize_wav',
          );
      final model = bootstrap.$2.toNativeUtf8();
      final vad = bootstrap.$3.toNativeUtf8();
      final handle = create(model, vad);
      malloc.free(model);
      malloc.free(vad);
      if (handle == nullptr) throw StateError('FunASR 原生模型初始化失败');
      receive.listen((message) {
        final command = message as (String, String, SendPort?);
        if (command.$1 == 'dispose') {
          destroy(handle);
          receive.close();
          return;
        }
        final path = command.$2.toNativeUtf8();
        const capacity = 16 * 1024;
        final output = malloc<Uint8>(capacity).cast<Utf8>();
        try {
          final length = recognize(handle, path, output, capacity);
          if (length < 0) {
            command.$3!.send(['FunASR 识别失败', length]);
          } else {
            command.$3!.send(output.toDartString(length: length));
          }
        } finally {
          malloc.free(output);
          malloc.free(path);
        }
      });
    } on Object catch (error) {
      receive.listen((message) {
        final command = message as (String, String, SendPort?);
        command.$3?.send(['FunASR 原生库不可用', error.toString()]);
      });
    }
  }
}
