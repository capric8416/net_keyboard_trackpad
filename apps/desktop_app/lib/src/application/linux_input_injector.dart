import 'package:flutter/services.dart';
import 'package:remote_input_core/remote_input_core.dart';

final class LinuxInputInjector implements ControlledDeviceInputInjector {
  static const channel = MethodChannel('net_keyboard/input');

  Future<bool> isAvailable() async =>
      await channel.invokeMethod<bool>('isAvailable') ?? false;

  Future<LinuxInputStatus> status({bool request = false}) async =>
      LinuxInputStatus.fromMap(
        (await channel.invokeMapMethod<String, Object?>(
          request ? 'requestAccess' : 'inputStatus',
        ))!,
      );

  Future<void> releaseAccess() async {
    await channel.invokeMethod<Object?>('releaseAccess');
  }

  // Wayland Clipboard portal uses CLIPBOARD; terminal emulators commonly use
  // Ctrl+Shift+V instead of Ctrl+V. Controlled by the desktop status page.
  static bool terminalPaste = false;

  @override
  Future<int> injectKeyStroke(KeyStroke stroke) => _send('keyStroke', {
    'key': stroke.key.name,
    'modifiers': stroke.modifierBits,
  });
  @override
  Future<int> injectText(String text) =>
      _send('text', {'text': text, 'terminalPaste': terminalPaste ? 1 : 0});
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

final class LinuxInputStatus {
  const LinuxInputStatus({
    required this.backend,
    required this.ready,
    required this.busy,
    required this.clipboard,
    required this.message,
  });

  factory LinuxInputStatus.fromMap(Map<String, Object?> map) =>
      LinuxInputStatus(
        backend: map['backend']! as String,
        ready: map['ready']! as bool,
        busy: map['busy']! as bool,
        clipboard: map['clipboard'] as bool? ?? false,
        message: map['message']! as String,
      );

  final String backend;
  final bool ready;
  final bool busy;
  final bool clipboard;
  final String message;
}
