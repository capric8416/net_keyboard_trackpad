import 'package:flutter/services.dart';
import 'package:remote_input_core/remote_input_core.dart';

final class MacOSInputInjector implements ControlledDeviceInputInjector {
  static const channel = MethodChannel('net_keyboard/input');

  Future<bool> isTrusted({bool prompt = false}) async =>
      await channel.invokeMethod<bool>('isTrusted', {'prompt': prompt}) ??
      false;

  @override
  Future<int> injectKeyStroke(KeyStroke stroke) => _send('keyStroke', {
    'key': stroke.key.name,
    'modifiers': stroke.modifierBits,
  });
  @override
  Future<int> injectText(String text) => _send('text', {'text': text});
  @override
  Future<int> injectPointer({
    int deltaX = 0,
    int deltaY = 0,
    int wheelDelta = 0,
    int horizontalWheelDelta = 0,
    PointerButton button = PointerButton.none,
    bool buttonDown = false,
  }) => _send('pointer', {
    'deltaX': deltaX,
    'deltaY': deltaY,
    'wheelDelta': wheelDelta,
    'horizontalWheelDelta': horizontalWheelDelta,
    'button': button.name,
    'buttonDown': buttonDown,
  });
  Future<int> _send(String method, Map<String, Object> args) async =>
      (await channel.invokeMethod<int>(method, args))!;
}
