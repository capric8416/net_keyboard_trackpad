import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grpc/grpc.dart';
import 'package:remote_input_core/remote_input_core.dart' as core;
import 'package:remote_input_protocol/remote_input_protocol.dart' as protocol;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract interface class RemoteInputGateway {
  core.ConnectionStatus get status;
  Listenable get statusChanges;
  Future<void> sendKeyStroke(core.KeyStroke stroke, {required bool repeated});
  Future<void> sendText(String text);
  Future<void> sendPointer(protocol.PointerInput input);
  Future<void> disconnect();
}

final class ServerProfile {
  const ServerProfile({
    required this.id,
    required this.host,
    required this.port,
    required this.fingerprint,
    required this.clientId,
    this.deviceId,
    this.token,
  });
  final String id;
  final String host;
  final int port;
  final String fingerprint;
  final String clientId;
  final String? deviceId;
  final String? token;
  bool get isPaired => deviceId != null && token != null;
}

final class ProfileStore {
  ProfileStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  static const _profilesKey = 'server_profiles_v2';
  static const _activeProfileKey = 'active_server_profile_id';

  Future<List<ServerProfile>> loadAll() async {
    final preferences = await SharedPreferences.getInstance();
    await _migrateLegacyProfile(preferences);
    final encoded = preferences.getString(_profilesKey);
    if (encoded == null) return const [];
    final entries = (jsonDecode(encoded) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return Future.wait(entries.map(_hydrate));
  }

  Future<ServerProfile?> loadActive() async {
    final preferences = await SharedPreferences.getInstance();
    final profiles = await loadAll();
    if (profiles.isEmpty) return null;
    final activeId = preferences.getString(_activeProfileKey);
    return profiles.where((profile) => profile.id == activeId).firstOrNull ??
        profiles.first;
  }

  Future<ServerProfile> prepareConnection(
    String host,
    int port,
    String fingerprint,
  ) async {
    final normalized = _normalizeFingerprint(fingerprint);
    final preferences = await SharedPreferences.getInstance();
    var clientId = preferences.getString('client_instance_id');
    clientId ??= const Uuid().v4();
    await preferences.setString('client_instance_id', clientId);
    return ServerProfile(
      id: const Uuid().v4(),
      host: host,
      port: port,
      fingerprint: normalized,
      clientId: clientId,
    );
  }

  Future<void> setActive(String id) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_activeProfileKey, id);
  }

  Future<void> delete(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final profiles = await loadAll();
    final remaining = profiles.where((profile) => profile.id != id).toList();
    await Future.wait([
      _writeProfiles(preferences, remaining),
      _storage.delete(key: _deviceKey(id)),
      _storage.delete(key: _tokenKey(id)),
    ]);
    if (preferences.getString(_activeProfileKey) == id) {
      if (remaining.isEmpty) {
        await preferences.remove(_activeProfileKey);
      } else {
        await preferences.setString(_activeProfileKey, remaining.first.id);
      }
    }
  }

  Future<ServerProfile> _hydrate(Map<String, dynamic> entry) async {
    final id = entry['id']! as String;
    return ServerProfile(
      id: id,
      host: entry['host']! as String,
      port: entry['port']! as int,
      fingerprint: entry['fingerprint']! as String,
      clientId: entry['clientId']! as String,
      deviceId: await _storage.read(key: _deviceKey(id)),
      token: await _storage.read(key: _tokenKey(id)),
    );
  }

  Future<void> _migrateLegacyProfile(SharedPreferences preferences) async {
    if (preferences.containsKey(_profilesKey)) return;
    final host = preferences.getString('server_host');
    final port = preferences.getInt('server_port');
    final fingerprint = preferences.getString('server_fingerprint');
    var clientId = preferences.getString('client_instance_id');
    if (clientId == null) {
      clientId = const Uuid().v4();
      await preferences.setString('client_instance_id', clientId);
    }
    if (host == null || port == null || fingerprint == null) {
      await preferences.setString(_profilesKey, '[]');
      return;
    }
    final id = const Uuid().v4();
    final profile = ServerProfile(
      id: id,
      host: host,
      port: port,
      fingerprint: fingerprint,
      clientId: clientId,
      deviceId: await _storage.read(key: 'paired_device_id'),
      token: await _storage.read(key: 'bearer_token'),
    );
    await _writeProfiles(preferences, [profile]);
    await preferences.setString(_activeProfileKey, id);
    if (profile.deviceId != null) {
      await _storage.write(key: _deviceKey(id), value: profile.deviceId);
    }
    if (profile.token != null) {
      await _storage.write(key: _tokenKey(id), value: profile.token);
    }
    await Future.wait([
      _storage.delete(key: 'paired_device_id'),
      _storage.delete(key: 'bearer_token'),
      preferences.remove('server_host'),
      preferences.remove('server_port'),
      preferences.remove('server_fingerprint'),
    ]);
  }

  Future<void> _writeProfiles(
    SharedPreferences preferences,
    List<ServerProfile> profiles,
  ) async {
    await preferences.setString(
      _profilesKey,
      jsonEncode(
        profiles
            .map(
              (profile) => {
                'id': profile.id,
                'host': profile.host,
                'port': profile.port,
                'fingerprint': profile.fingerprint,
                'clientId': profile.clientId,
              },
            )
            .toList(),
      ),
    );
  }

  static String _deviceKey(String id) => 'paired_device_id_$id';
  static String _tokenKey(String id) => 'bearer_token_$id';

  Future<void> _upsertProfile(ServerProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    final profiles = await loadAll();
    final index = profiles.indexWhere((item) => item.id == profile.id);
    if (index < 0) {
      profiles.add(profile);
    } else {
      profiles[index] = profile;
    }
    await _writeProfiles(preferences, profiles);
  }

  Future<ServerProfile> savePairing(
    ServerProfile profile,
    String deviceId,
    List<int> token,
  ) async {
    final encoded = base64UrlEncode(token);
    await Future.wait([
      _storage.write(key: _deviceKey(profile.id), value: deviceId),
      _storage.write(key: _tokenKey(profile.id), value: encoded),
    ]);
    final paired = ServerProfile(
      id: profile.id,
      host: profile.host,
      port: profile.port,
      fingerprint: profile.fingerprint,
      clientId: profile.clientId,
      deviceId: deviceId,
      token: encoded,
    );
    await _upsertProfile(paired);
    await setActive(paired.id);
    return paired;
  }
}

final class GrpcRemoteInputGateway implements RemoteInputGateway {
  GrpcRemoteInputGateway({ProfileStore? profileStore})
    : _profileStore = profileStore ?? ProfileStore();

  final ProfileStore _profileStore;
  final ValueNotifier<core.ConnectionStatus> _status = ValueNotifier(
    const core.ConnectionStatus(
      core.ConnectionPhase.disconnected,
      message: '尚未配置被控端',
    ),
  );
  ClientChannel? _channel;
  protocol.RemoteInputServiceClient? _client;
  StreamController<protocol.ClientEnvelope>? _outgoing;
  StreamSubscription<protocol.ServerEnvelope>? _responses;
  final Map<String, Completer<void>> _pending = {};
  ServerProfile? _profile;
  int _sequence = 0;
  Timer? _heartbeat;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _autoReconnect = false;

  @override
  core.ConnectionStatus get status => _status.value;
  ServerProfile? get activeProfile => _profile;
  bool get hasPairedProfile => _profile?.isPaired ?? false;
  bool get connectionEnabled => _autoReconnect || status.canSend;
  @override
  Listenable get statusChanges => _status;

  Future<ServerProfile?> loadProfile() async {
    _profile = await _profileStore.loadActive();
    return _profile;
  }

  Future<List<ServerProfile>> loadProfiles() => _profileStore.loadAll();

  Future<void> configureAndPair({
    required String host,
    required int port,
    required String fingerprint,
    required String totp,
  }) async {
    final previousProfile = await _profileStore.loadActive();
    await disconnect();
    final profile = await _profileStore.prepareConnection(
      host,
      port,
      fingerprint,
    );
    try {
      _profile = profile;
      _setStatus(core.ConnectionPhase.tlsConnecting, '正在验证 TLS 证书…');
      _createClient(profile);
      final info = await _client!.getServerInfo(
        protocol.ServerInfoRequest(),
        options: CallOptions(timeout: const Duration(seconds: 10)),
      );
      if (_normalizeFingerprint(info.certificateSha256) !=
          profile.fingerprint) {
        throw StateError('被控端返回的证书指纹与输入值不一致');
      }
      _setStatus(core.ConnectionPhase.authenticating, '正在校验 TOTP…');
      final challenge = await _client!.createPairingChallenge(
        protocol.PairingChallengeRequest(clientInstanceId: profile.clientId),
        options: CallOptions(timeout: const Duration(seconds: 10)),
      );
      final response = await _client!.pair(
        protocol.PairRequest(
          challengeId: challenge.challengeId,
          clientInstanceId: profile.clientId,
          clientName: Platform.localHostname,
          totpCode: totp,
          clientNonce: _randomNonce(),
          protocolVersion: protocol.ProtocolVersion(
            major: protocol.RemoteInputProtocolVersion.major,
            minor: protocol.RemoteInputProtocolVersion.minor,
          ),
        ),
        options: CallOptions(timeout: const Duration(seconds: 10)),
      );
      _profile = await _profileStore.savePairing(
        profile,
        response.pairedDeviceId,
        response.bearerToken,
      );
      await connect(_profile!);
    } on Object {
      await disconnect();
      _profile = previousProfile;
      rethrow;
    }
  }

  Future<void> connect(ServerProfile profile) async {
    if (!profile.isPaired) {
      _setStatus(core.ConnectionPhase.pairingRequired, '需要输入被控端验证码');
      return;
    }
    await disconnect();
    await _profileStore.setActive(profile.id);
    _autoReconnect = true;
    _profile = profile;
    _setStatus(
      core.ConnectionPhase.tlsConnecting,
      '正在连接 ${profile.host}:${profile.port}',
    );
    _createClient(profile);
    _setStatus(core.ConnectionPhase.openingControl, '正在打开控制会话…');
    _outgoing = StreamController<protocol.ClientEnvelope>();
    final options = CallOptions(
      metadata: {
        'device-id': profile.deviceId!,
        'authorization': 'Bearer ${profile.token!}',
      },
    );
    final stream = _client!.control(_outgoing!.stream, options: options);
    final hello = Completer<void>();
    _responses = stream.listen(
      (response) {
        if (response.hasHello() && !hello.isCompleted) hello.complete();
        if (response.hasResult()) {
          final pending = _pending.remove(response.result.eventId);
          if (pending != null && !pending.isCompleted) {
            response.result.success
                ? pending.complete()
                : pending.completeError(StateError(response.result.message));
          }
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!hello.isCompleted) hello.completeError(error, stack);
        _failPending(error, stack);
        _setStatus(core.ConnectionPhase.error, error.toString());
        _scheduleReconnect();
      },
      onDone: () {
        _failPending(StateError('被控端已关闭连接'));
        _setStatus(core.ConnectionPhase.disconnected, '连接已断开');
        _scheduleReconnect();
      },
    );
    _outgoing!.add(
      protocol.ClientEnvelope(
        sequence: Int64(++_sequence),
        eventId: const Uuid().v4(),
        hello: protocol.ClientHello(
          clientInstanceId: profile.clientId,
          clientName: Platform.localHostname,
          protocolVersion: protocol.ProtocolVersion(
            major: protocol.RemoteInputProtocolVersion.major,
            minor: protocol.RemoteInputProtocolVersion.minor,
          ),
          capabilities: [
            protocol.Capability.CAPABILITY_KEY_STROKE,
            protocol.Capability.CAPABILITY_UNICODE_TEXT,
            protocol.Capability.CAPABILITY_POINTER,
          ],
        ),
      ),
    );
    await hello.future.timeout(const Duration(seconds: 10));
    _setStatus(
      core.ConnectionPhase.connected,
      '已连接 ${profile.host}:${profile.port}',
    );
    _reconnectAttempt = 0;
    _heartbeat = Timer.periodic(const Duration(seconds: 10), (_) {
      _outgoing?.add(
        protocol.ClientEnvelope(
          sequence: Int64(++_sequence),
          eventId: const Uuid().v4(),
          ping: protocol.Ping(
            sentAtUnixMs: Int64(DateTime.now().millisecondsSinceEpoch),
          ),
        ),
      );
    });
  }

  Future<void> deleteProfile(ServerProfile profile) async {
    if (_profile?.id == profile.id) {
      await disconnect();
      _profile = null;
    }
    await _profileStore.delete(profile.id);
    _profile ??= await _profileStore.loadActive();
  }

  void _createClient(ServerProfile profile) {
    final expected = _normalizeFingerprint(profile.fingerprint);
    _channel = ClientChannel(
      profile.host,
      port: profile.port,
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          authority: 'localhost',
          onBadCertificate: (certificate, _) {
            final actual = sha256
                .convert(certificate.der)
                .toString()
                .toUpperCase();
            return actual == expected.replaceAll(':', '');
          },
        ),
      ),
    );
    _client = protocol.RemoteInputServiceClient(_channel!);
  }

  @override
  Future<void> sendKeyStroke(core.KeyStroke stroke, {required bool repeated}) =>
      _send(
        protocol.ClientEnvelope(
          keyStroke: protocol.KeyStroke(
            key: protocol.SemanticKey.valueOf(stroke.key.index + 1)!,
            modifierBits: stroke.modifierBits,
            repeated: repeated,
          ),
        ),
      );

  @override
  Future<void> sendText(String text) => _send(
    protocol.ClientEnvelope(textInput: protocol.TextInput(text: text)),
    timeout: const Duration(seconds: 10),
  );

  @override
  Future<void> sendPointer(protocol.PointerInput input) =>
      _send(protocol.ClientEnvelope(pointerInput: input));

  Future<void> _send(
    protocol.ClientEnvelope envelope, {
    Duration timeout = const Duration(seconds: 3),
  }) {
    if (!status.canSend || _outgoing == null) {
      return Future.error(StateError('尚未连接被控端'));
    }
    final id = const Uuid().v4();
    envelope
      ..sequence = Int64(++_sequence)
      ..eventId = id;
    final completer = Completer<void>();
    _pending[id] = completer;
    _outgoing!.add(envelope);
    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _pending.remove(id);
        throw TimeoutException('被控端未在期限内确认命令');
      },
    );
  }

  @override
  Future<void> disconnect() async {
    _autoReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeat?.cancel();
    _heartbeat = null;
    await _outgoing?.close();
    _outgoing = null;
    await _responses?.cancel();
    _responses = null;
    await _channel?.shutdown();
    _channel = null;
    _client = null;
    _sequence = 0;
    _failPending(StateError('连接已关闭'));
    _setStatus(core.ConnectionPhase.disconnected, '未连接');
  }

  void _scheduleReconnect() {
    final profile = _profile;
    if (!_autoReconnect || profile == null || !profile.isPaired) return;
    _reconnectTimer?.cancel();
    final delays = [1, 2, 4, 8, 15, 30];
    final seconds = delays[_reconnectAttempt.clamp(0, delays.length - 1)];
    _reconnectAttempt++;
    _setStatus(core.ConnectionPhase.backingOff, '$seconds 秒后重新连接…');
    _reconnectTimer = Timer(Duration(seconds: seconds), () async {
      if (!_autoReconnect) return;
      try {
        await connect(profile);
      } on Object catch (error) {
        _setStatus(core.ConnectionPhase.error, error.toString());
        _autoReconnect = true;
        _scheduleReconnect();
      }
    });
  }

  void _failPending(Object error, [StackTrace? stack]) {
    for (final pending in _pending.values) {
      if (!pending.isCompleted) pending.completeError(error, stack);
    }
    _pending.clear();
  }

  void _setStatus(core.ConnectionPhase phase, String message) =>
      _status.value = core.ConnectionStatus(phase, message: message);

  static List<int> _randomNonce() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256));
  }
}

String _normalizeFingerprint(String value) => value
    .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
    .toUpperCase()
    .replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)}:')
    .replaceFirst(RegExp(r':$'), '');
