import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_input_windows/desktop_input_windows.dart';
import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'macos_input_injector.dart';
import 'linux_input_injector.dart';
import '../security/server_identity.dart';
import '../security/totp.dart';
import '../server/remote_input_service.dart';

final class ControlledDeviceController extends ChangeNotifier {
  ServerIdentity? _identity;
  Server? _server;
  Timer? _codeTimer;
  int _port = 39091;
  String _status = '正在初始化安全身份…';
  String? _connectedDevice;
  Object? _error;
  List<NetworkInterface> _interfaces = const [];
  Timer? _inputTimer;
  LinuxInputStatus? linuxInputStatus;
  bool linuxAuthorizationPending = false;
  bool _checkingLinuxInput = false;
  bool _disposed = false;

  Future<void> checkLinuxInput({bool request = false}) async {
    if (_disposed || !Platform.isLinux || (!request && _checkingLinuxInput)) {
      return;
    }
    if (request && linuxAuthorizationPending) return;
    _checkingLinuxInput = true;
    if (request) {
      linuxAuthorizationPending = true;
      if (!_disposed) notifyListeners();
    }
    try {
      linuxInputStatus = await LinuxInputInjector().status(request: request);
    } catch (error) {
      linuxInputStatus = LinuxInputStatus(
        backend: 'unknown',
        ready: false,
        busy: false,
        clipboard: false,
        message: '无法检查 Linux 输入状态：$error',
      );
    } finally {
      _checkingLinuxInput = false;
      if (request) linuxAuthorizationPending = false;
      if (!_disposed) notifyListeners();
    }
  }

  bool get terminalPaste => LinuxInputInjector.terminalPaste;
  void setTerminalPaste(bool value) {
    LinuxInputInjector.terminalPaste = value;
    notifyListeners();
  }

  Future<void> releaseLinuxInput() async {
    if (!Platform.isLinux) return;
    await LinuxInputInjector().releaseAccess();
    await checkLinuxInput();
  }

  bool accessibilityTrusted = false;
  Future<void> checkAccessibility({bool prompt = false}) async {
    if (!Platform.isMacOS) return;
    accessibilityTrusted = await MacOSInputInjector().isTrusted(prompt: prompt);
    notifyListeners();
  }

  int get port => _port;
  String get status => _status;
  String? get connectedDevice => _connectedDevice;
  Object? get error => _error;
  bool get isListening => _server != null;
  String get fingerprint => _identity?.certificateFingerprint ?? '生成中…';
  String get pairingCode =>
      _identity == null ? '------' : totpCode(_identity!.totpSecret);
  List<String> get addresses => [
    for (final interface in _interfaces)
      for (final address in interface.addresses)
        if (address.type == InternetAddressType.IPv4 && !address.isLoopback)
          '${address.address}:$_port',
  ];

  Future<void> initialize() async {
    try {
      await checkAccessibility();
      await checkLinuxInput();
      if (Platform.isLinux) {
        _inputTimer = Timer.periodic(const Duration(seconds: 2), (_) {
          if (!linuxAuthorizationPending) unawaited(checkLinuxInput());
        });
      }
      final preferences = await SharedPreferences.getInstance();
      _port = preferences.getInt('listen_port') ?? 39091;
      _interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      final store = ServerIdentityStore();
      _identity = await store.loadOrCreate();
      final service = RemoteInputService(
        identity: _identity!,
        identityStore: store,
        input: Platform.isLinux
            ? LinuxInputInjector()
            : Platform.isMacOS
            ? MacOSInputInjector()
            : WindowsInputInjector(),
        onConnectionChanged: (connected, peerAddress) {
          _connectedDevice = connected ? peerAddress : null;
          _status = connected ? '已连接：$peerAddress' : '等待连接';
          notifyListeners();
        },
      );
      final server = Server.create(services: [service]);
      await server.serve(
        address: InternetAddress.anyIPv4,
        port: _port,
        security: ServerTlsCredentials(
          certificate: utf8.encode(_identity!.certificatePem),
          privateKey: utf8.encode(_identity!.privateKeyPem),
        ),
      );
      _server = server;
      _status = '等待连接';
      _codeTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => notifyListeners(),
      );
    } on SocketException catch (error) {
      if ([10048, 48, 98].contains(error.osError?.errorCode)) {
        _error =
            '端口 $_port 已被占用。请检查是否已有受控端在系统托盘运行，'
            '或是否有其他程序正在使用该端口。';
        _status = '端口已被占用';
      } else {
        _error = error;
        _status = '监听启动失败';
      }
    } on Object catch (error) {
      _error = error;
      _status = '监听启动失败';
    }
    notifyListeners();
  }

  Future<void> shutdown() async {
    _codeTimer?.cancel();
    _inputTimer?.cancel();
    if (Platform.isLinux) await LinuxInputInjector().releaseAccess();
    await _server?.shutdown();
    _server = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _codeTimer?.cancel();
    _inputTimer?.cancel();
    super.dispose();
  }
}
