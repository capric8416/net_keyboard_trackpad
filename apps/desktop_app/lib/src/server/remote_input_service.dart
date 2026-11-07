import 'dart:async';
import 'dart:convert';

import 'package:desktop_input_windows/desktop_input_windows.dart' as desktop;
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:remote_input_core/remote_input_core.dart' as core;
import 'package:remote_input_protocol/remote_input_protocol.dart' as protocol;
import 'package:uuid/uuid.dart';

import '../security/server_identity.dart';
import '../security/totp.dart';

final class RemoteInputService extends protocol.RemoteInputServiceBase {
  RemoteInputService({
    required ServerIdentity identity,
    required ServerIdentityStore identityStore,
    required desktop.WindowsInputInjector input,
    required this.onConnectionChanged,
  }) : _identity = identity,
       _identityStore = identityStore,
       _input = input;

  ServerIdentity _identity;
  final ServerIdentityStore _identityStore;
  final desktop.WindowsInputInjector _input;
  final void Function(bool connected, String? peerAddress) onConnectionChanged;
  final Map<String, _Challenge> _challenges = {};
  final Set<String> _recentEvents = {};
  bool _controllerActive = false;
  int _failedPairingAttempts = 0;
  DateTime? _pairingLockedUntil;

  @override
  Future<protocol.ServerInfoResponse> getServerInfo(
    ServiceCall call,
    protocol.ServerInfoRequest request,
  ) async => protocol.ServerInfoResponse(
    serverId: _identity.serverId,
    displayName: '网络键盘接收端',
    protocolVersion: _version(),
    certificateSha256: _identity.certificateFingerprint,
    capabilities: _capabilities,
    pairingEnabled: true,
  );

  @override
  Future<protocol.PairingChallengeResponse> createPairingChallenge(
    ServiceCall call,
    protocol.PairingChallengeRequest request,
  ) async {
    if (_pairingLockedUntil?.isAfter(DateTime.now()) ?? false) {
      throw GrpcError.resourceExhausted('配对失败次数过多，请稍后重试');
    }
    _removeExpiredChallenges();
    final id = const Uuid().v4();
    final challenge = _Challenge(
      clientId: request.clientInstanceId,
      nonce: secureRandomBytes(32),
      expiresAt: DateTime.now().add(const Duration(minutes: 2)),
    );
    _challenges[id] = challenge;
    return protocol.PairingChallengeResponse(
      challengeId: id,
      serverNonce: challenge.nonce,
      expiresAtUnixMs: Int64(challenge.expiresAt.millisecondsSinceEpoch),
    );
  }

  @override
  Future<protocol.PairResponse> pair(
    ServiceCall call,
    protocol.PairRequest request,
  ) async {
    final challenge = _challenges.remove(request.challengeId);
    if (challenge == null ||
        challenge.clientId != request.clientInstanceId ||
        challenge.expiresAt.isBefore(DateTime.now())) {
      throw GrpcError.failedPrecondition('配对请求已过期');
    }
    if (request.protocolVersion.major != 1) {
      throw GrpcError.failedPrecondition('协议主版本不兼容');
    }
    if (!verifyTotp(_identity.totpSecret, request.totpCode)) {
      _failedPairingAttempts++;
      if (_failedPairingAttempts >= 5) {
        _pairingLockedUntil = DateTime.now().add(const Duration(minutes: 1));
        _failedPairingAttempts = 0;
      }
      throw GrpcError.permissionDenied('TOTP 验证码错误');
    }
    _failedPairingAttempts = 0;
    _pairingLockedUntil = null;
    final token = secureRandomBytes(32);
    final deviceId = const Uuid().v4();
    final device = PairedDevice(
      id: deviceId,
      name: request.clientName.trim().isEmpty ? 'Android' : request.clientName,
      tokenHash: ServerIdentityStore.tokenHash(token),
    );
    _identity.pairedDevices[deviceId] = device;
    await _identityStore.save(_identity);
    return protocol.PairResponse(
      pairedDeviceId: deviceId,
      bearerToken: token,
      serverId: _identity.serverId,
      protocolVersion: _version(),
      capabilities: _capabilities,
      tokenCreatedAtUnixMs: Int64(DateTime.now().millisecondsSinceEpoch),
    );
  }

  @override
  Stream<protocol.ServerEnvelope> control(
    ServiceCall call,
    Stream<protocol.ClientEnvelope> request,
  ) async* {
    final device = _authenticate(call);
    if (_controllerActive) throw GrpcError.resourceExhausted('已有控制设备连接');
    _controllerActive = true;
    onConnectionChanged(true, call.remoteAddress?.address ?? device.name);
    var expectedSequence = 1;
    var receivedHello = false;
    try {
      // A mobile device can lose its network without immediately closing the
      // TCP/HTTP2 stream. Expire such stale sessions so a later connection is
      // not blocked by _controllerActive forever.
      await for (final envelope in request.timeout(
        const Duration(seconds: 35),
      )) {
        if (envelope.sequence.toInt() != expectedSequence) {
          yield _result(
            envelope,
            false,
            protocol.ErrorCode.ERROR_CODE_INVALID_SEQUENCE,
            'sequence 应为 $expectedSequence',
          );
          continue;
        }
        expectedSequence++;
        if (!receivedHello) {
          if (!envelope.hasHello() ||
              envelope.hello.protocolVersion.major != 1) {
            throw GrpcError.failedPrecondition('首条控制消息必须是兼容的 ClientHello');
          }
          receivedHello = true;
          yield protocol.ServerEnvelope(
            acknowledgedSequence: envelope.sequence,
            hello: protocol.ServerHello(
              serverId: _identity.serverId,
              displayName: '网络键盘接收端',
              protocolVersion: _version(),
              capabilities: _capabilities,
              heartbeatIntervalSeconds: 10,
            ),
          );
          continue;
        }
        if (envelope.hasPing()) {
          yield protocol.ServerEnvelope(
            acknowledgedSequence: envelope.sequence,
            pong: protocol.Pong(
              clientSentAtUnixMs: envelope.ping.sentAtUnixMs,
              serverSentAtUnixMs: Int64(DateTime.now().millisecondsSinceEpoch),
            ),
          );
          continue;
        }
        if (envelope.eventId.isEmpty ||
            _recentEvents.contains(envelope.eventId)) {
          yield _result(
            envelope,
            false,
            protocol.ErrorCode.ERROR_CODE_DUPLICATE_EVENT,
            'event_id 为空或重复',
          );
          continue;
        }
        _rememberEvent(envelope.eventId);
        try {
          final count = _inject(envelope);
          yield _result(
            envelope,
            true,
            protocol.ErrorCode.ERROR_CODE_OK,
            'OK',
            count,
          );
        } on Object catch (error) {
          final noTarget = error.toString().contains('NO_FOREGROUND_TARGET');
          yield _result(
            envelope,
            false,
            noTarget
                ? protocol.ErrorCode.ERROR_CODE_NO_FOREGROUND_TARGET
                : protocol.ErrorCode.ERROR_CODE_INPUT_BLOCKED,
            error.toString(),
          );
        }
      }
    } on TimeoutException {
      throw GrpcError.unavailable('控制连接心跳超时');
    } finally {
      _controllerActive = false;
      onConnectionChanged(false, null);
    }
  }

  int _inject(protocol.ClientEnvelope envelope) {
    if (envelope.hasKeyStroke()) {
      final wireKey = envelope.keyStroke.key.value;
      if (wireKey <= 0 || wireKey > core.SemanticKey.values.length) {
        throw ArgumentError('不支持的语义键');
      }
      return _input.injectKeyStroke(
        core.KeyStroke(
          key: core.SemanticKey.values[wireKey - 1],
          modifierBits: envelope.keyStroke.modifierBits,
        ),
      );
    }
    if (envelope.hasTextInput()) {
      final text = envelope.textInput.text;
      if (text.isEmpty || text.length > 8192 || text.contains('\u0000')) {
        throw ArgumentError('文本为空、过长或包含 NUL');
      }
      return _input.injectText(text);
    }
    if (envelope.hasPointerInput()) {
      final pointer = envelope.pointerInput;
      final button = switch (pointer.button) {
        protocol.PointerButton.POINTER_BUTTON_LEFT =>
          desktop.PointerButton.left,
        protocol.PointerButton.POINTER_BUTTON_RIGHT =>
          desktop.PointerButton.right,
        protocol.PointerButton.POINTER_BUTTON_MIDDLE =>
          desktop.PointerButton.middle,
        _ => desktop.PointerButton.none,
      };
      return _input.injectPointer(
        deltaX: pointer.deltaX.clamp(-4096, 4096) as int,
        deltaY: pointer.deltaY.clamp(-4096, 4096) as int,
        wheelDelta: pointer.wheelDelta.clamp(-1200, 1200) as int,
        horizontalWheelDelta:
            pointer.horizontalWheelDelta.clamp(-1200, 1200) as int,
        button: button,
        buttonDown: pointer.buttonDown,
      );
    }
    throw ArgumentError('未知控制命令');
  }

  PairedDevice _authenticate(ServiceCall call) {
    final metadata = call.clientMetadata ?? const <String, String>{};
    final deviceId = metadata['device-id'];
    final authorization = metadata['authorization'];
    if (deviceId == null ||
        authorization == null ||
        !authorization.startsWith('Bearer ')) {
      throw GrpcError.unauthenticated('缺少设备凭据');
    }
    final device = _identity.pairedDevices[deviceId];
    if (device == null) throw GrpcError.unauthenticated('设备未配对或已撤销');
    try {
      final token = base64Url.decode(authorization.substring(7));
      if (ServerIdentityStore.tokenHash(token) != device.tokenHash) {
        throw GrpcError.unauthenticated('令牌无效');
      }
    } on FormatException {
      throw GrpcError.unauthenticated('令牌格式无效');
    }
    return device;
  }

  protocol.ServerEnvelope _result(
    protocol.ClientEnvelope envelope,
    bool success,
    protocol.ErrorCode code,
    String message, [
    int count = 0,
  ]) => protocol.ServerEnvelope(
    acknowledgedSequence: envelope.sequence,
    result: protocol.CommandResult(
      eventId: envelope.eventId,
      success: success,
      errorCode: code,
      message: message,
      injectedEventCount: count,
    ),
  );

  void _rememberEvent(String eventId) {
    _recentEvents.add(eventId);
    if (_recentEvents.length > 2048) _recentEvents.remove(_recentEvents.first);
  }

  void _removeExpiredChallenges() => _challenges.removeWhere(
    (_, challenge) => challenge.expiresAt.isBefore(DateTime.now()),
  );

  protocol.ProtocolVersion _version() => protocol.ProtocolVersion(
    major: protocol.RemoteInputProtocolVersion.major,
    minor: protocol.RemoteInputProtocolVersion.minor,
  );

  static final _capabilities = [
    protocol.Capability.CAPABILITY_KEY_STROKE,
    protocol.Capability.CAPABILITY_UNICODE_TEXT,
    protocol.Capability.CAPABILITY_POINTER,
  ];
}

final class _Challenge {
  const _Challenge({
    required this.clientId,
    required this.nonce,
    required this.expiresAt,
  });
  final String clientId;
  final List<int> nonce;
  final DateTime expiresAt;
}
