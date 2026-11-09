import 'package:flutter/foundation.dart';
import 'package:remote_input_core/remote_input_core.dart';
import 'package:remote_input_protocol/remote_input_protocol.dart' as protocol;

import '../infrastructure/remote_input_gateway.dart';
import '../infrastructure/funasr_service.dart';

final class KeyboardController extends ChangeNotifier {
  KeyboardController(this._gateway, {LocalSpeechService? speech})
    : _speech = speech ?? LocalSpeechService(),
      _connectionStatus = _gateway.status {
    Standard64Layout.validate();
    _gateway.statusChanges.addListener(_syncConnectionStatus);
  }

  final RemoteInputGateway _gateway;
  final LocalSpeechService _speech;
  ModifierSet _modifiers = const ModifierSet.empty();
  ConnectionStatus _connectionStatus;
  VoiceInputState _voiceState = const VoiceInputState.ready();
  String? _lastError;
  bool _fnSelected = false;

  ModifierSet get modifiers => _modifiers;
  ConnectionStatus get connectionStatus => _connectionStatus;
  VoiceInputState get voiceState => _voiceState;
  String? get lastError => _lastError;
  bool get fnSelected => _fnSelected;
  bool get canSend => _connectionStatus.canSend;

  void updateConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }

  void toggleModifier(ModifierKey modifier) {
    _modifiers = _modifiers.toggle(modifier);
    notifyListeners();
  }

  void toggleFn() {
    _fnSelected = !_fnSelected;
    notifyListeners();
  }

  Future<void> pressKey(SemanticKey key, {bool repeated = false}) async {
    if (!canSend) {
      _setError(_connectionStatus.message ?? '尚未连接受控端');
      return;
    }
    final stroke = KeyStroke(key: key, modifierBits: _modifiers.bits);
    try {
      await _gateway.sendKeyStroke(stroke, repeated: repeated);
      _lastError = null;
    } on Object catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> sendPointer(protocol.PointerInput input) async {
    if (!canSend) return;
    try {
      await _gateway.sendPointer(input);
    } on Object catch (error) {
      _setError(error.toString());
    }
  }

  void setVoiceState(VoiceInputState state) {
    _voiceState = state;
    notifyListeners();
  }

  Future<void> startVoiceRecording(String operationId) async {
    try {
      await _speech.startRecording();
      _voiceState = VoiceInputState(
        VoiceInputPhase.recording,
        operationId: operationId,
      );
    } on Object catch (error) {
      _voiceState = VoiceInputState(
        VoiceInputPhase.unavailable,
        operationId: operationId,
        message: error.toString(),
      );
      _setError(error.toString());
      return;
    }
    notifyListeners();
  }

  Future<void> finishVoiceRecording() async {
    final operationId = _voiceState.operationId;
    _voiceState = VoiceInputState(
      VoiceInputPhase.recognizing,
      operationId: operationId,
    );
    notifyListeners();
    try {
      final text = await _speech.stopAndRecognize();
      _voiceState = VoiceInputState(
        VoiceInputPhase.reviewing,
        operationId: operationId,
        reviewText: text,
      );
      notifyListeners();
    } on Object catch (error) {
      _voiceState = VoiceInputState(
        VoiceInputPhase.ready,
        operationId: operationId,
        message: error.toString(),
      );
      _setError(error.toString());
    }
  }

  Future<void> cancelVoiceRecording() async {
    await _speech.cancel();
    _voiceState = const VoiceInputState.ready();
    notifyListeners();
  }

  Future<bool> confirmVoiceText() async {
    final text = _voiceState.reviewText?.trim();
    if (text == null || text.isEmpty || !canSend) return false;
    _voiceState = VoiceInputState(
      VoiceInputPhase.submitting,
      operationId: _voiceState.operationId,
      reviewText: text,
    );
    notifyListeners();
    try {
      await _gateway.sendText(text);
      _voiceState = const VoiceInputState.ready();
      _lastError = null;
      notifyListeners();
      return true;
    } on Object catch (error) {
      _voiceState = VoiceInputState(
        VoiceInputPhase.reviewing,
        operationId: _voiceState.operationId,
        reviewText: text,
        message: error.toString(),
      );
      _setError(error.toString());
      return false;
    }
  }

  void cancelVoiceText() {
    _voiceState = const VoiceInputState.ready();
    notifyListeners();
  }

  void dismissError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  void _setError(String message) {
    _lastError = message;
    notifyListeners();
  }

  void _syncConnectionStatus() {
    _connectionStatus = _gateway.status;
    notifyListeners();
  }

  @override
  void dispose() {
    _gateway.statusChanges.removeListener(_syncConnectionStatus);
    _gateway.disconnect();
    _speech.dispose();
    super.dispose();
  }
}
