import 'package:desktop_input_windows/desktop_input_windows.dart';
import 'package:remote_input_core/remote_input_core.dart';

void main() {
  WindowsKeyMap.validate();
  if (WindowsKeyMap.keys.length != SemanticKey.values.length) {
    throw StateError('not every SemanticKey has a Windows scan code');
  }
  if (WindowsKeyMap.modifiers.length != ModifierKey.values.length) {
    throw StateError('not every ModifierKey has a Windows scan code');
  }
  print(
    'Windows mapping validation passed: '
    '${WindowsKeyMap.keys.length} keys, '
    '${WindowsKeyMap.modifiers.length} modifiers',
  );
}

