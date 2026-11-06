import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:remote_input_core/remote_input_core.dart';
import 'package:win32/win32.dart';

import 'windows_key_map.dart';

enum PointerButton { none, left, right, middle }

final class WindowsInputInjector {
  WindowsInputInjector() {
    WindowsKeyMap.validate();
  }

  int injectKeyStroke(KeyStroke stroke) {
    final key = WindowsKeyMap.keys[stroke.key];
    if (key == null) throw ArgumentError('Unsupported key: ${stroke.key.name}');
    final modifiers = ModifierSet.fromBits(stroke.modifierBits).selected
        .map((item) => WindowsKeyMap.modifiers[item]!)
        .toList(growable: false);
    final events = <({WindowsKeyMapping key, bool up})>[
      for (final modifier in modifiers) (key: modifier, up: false),
      (key: key, up: false),
      (key: key, up: true),
      for (final modifier in modifiers.reversed) (key: modifier, up: true),
    ];
    return using((arena) {
      final inputs = arena<INPUT>(events.length);
      for (var index = 0; index < events.length; index++) {
        final event = events[index];
        final input = inputs[index];
        input.type = INPUT_KEYBOARD;
        input.ki
          ..wVk = const VIRTUAL_KEY(0)
          ..wScan = event.key.scanCode
          ..dwFlags =
              KEYEVENTF_SCANCODE |
              (event.key.extended ? KEYEVENTF_EXTENDEDKEY : 0) |
              (event.up ? KEYEVENTF_KEYUP : 0)
          ..time = 0
          ..dwExtraInfo = 0;
      }
      return _send(inputs, events.length);
    });
  }

  int injectText(String text) {
    if (text.isEmpty) return 0;
    if (GetForegroundWindow().address == 0) {
      throw StateError('NO_FOREGROUND_TARGET');
    }
    final units = text.codeUnits;
    return using((arena) {
      final inputs = arena<INPUT>(units.length * 2);
      for (var index = 0; index < units.length; index++) {
        for (var phase = 0; phase < 2; phase++) {
          final input = inputs[index * 2 + phase];
          input.type = INPUT_KEYBOARD;
          input.ki
            ..wVk = const VIRTUAL_KEY(0)
            ..wScan = units[index]
            ..dwFlags = KEYEVENTF_UNICODE | (phase == 1 ? KEYEVENTF_KEYUP : 0)
            ..time = 0
            ..dwExtraInfo = 0;
        }
      }
      return _send(inputs, units.length * 2);
    });
  }

  int injectPointer({
    int deltaX = 0,
    int deltaY = 0,
    int wheelDelta = 0,
    int horizontalWheelDelta = 0,
    PointerButton button = PointerButton.none,
    bool buttonDown = false,
  }) => using((arena) {
    var flags = 0;
    if (deltaX != 0 || deltaY != 0) flags |= MOUSEEVENTF_MOVE;
    if (wheelDelta != 0) flags |= MOUSEEVENTF_WHEEL;
    if (horizontalWheelDelta != 0) flags |= MOUSEEVENTF_HWHEEL;
    flags |= switch (button) {
      PointerButton.none => 0,
      PointerButton.left =>
        buttonDown ? MOUSEEVENTF_LEFTDOWN : MOUSEEVENTF_LEFTUP,
      PointerButton.right =>
        buttonDown ? MOUSEEVENTF_RIGHTDOWN : MOUSEEVENTF_RIGHTUP,
      PointerButton.middle =>
        buttonDown ? MOUSEEVENTF_MIDDLEDOWN : MOUSEEVENTF_MIDDLEUP,
    };
    if (flags == 0) return 0;
    final input = arena<INPUT>();
    input.ref
      ..type = INPUT_MOUSE
      ..mi.dx = deltaX
      ..mi.dy = deltaY
      ..mi.mouseData = wheelDelta != 0 ? wheelDelta : horizontalWheelDelta
      ..mi.dwFlags = MOUSE_EVENT_FLAGS(flags)
      ..mi.time = 0
      ..mi.dwExtraInfo = 0;
    return _send(input, 1);
  });

  int _send(Pointer<INPUT> inputs, int count) {
    final result = SendInput(count, inputs, sizeOf<INPUT>());
    if (result.value != count) {
      throw StateError(
        'SendInput injected ${result.value}/$count events; '
        'Win32 error ${result.error}',
      );
    }
    return result.value;
  }
}
