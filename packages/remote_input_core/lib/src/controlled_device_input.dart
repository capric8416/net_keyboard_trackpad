import 'dart:async';

import 'semantic_key.dart';

enum PointerButton { none, left, right, middle }

/// Platform-neutral input contract implemented by each controlled-device OS.
abstract interface class ControlledDeviceInputInjector {
  FutureOr<int> injectKeyStroke(KeyStroke stroke);
  FutureOr<int> injectText(String text);
  FutureOr<int> injectPointer({
    int deltaX = 0,
    int deltaY = 0,
    int wheelDelta = 0,
    int horizontalWheelDelta = 0,
    PointerButton button = PointerButton.none,
    bool buttonDown = false,
  });
}
