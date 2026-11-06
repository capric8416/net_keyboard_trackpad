import 'package:desktop_input_windows/desktop_input_windows.dart';
import 'package:remote_input_core/remote_input_core.dart';
import 'package:test/test.dart';

void main() {
  test('all semantic and modifier keys have Windows mappings', () {
    expect(WindowsKeyMap.validate, returnsNormally);
    expect(WindowsKeyMap.keys, hasLength(SemanticKey.values.length));
    expect(WindowsKeyMap.modifiers, hasLength(ModifierKey.values.length));
  });

  test('navigation and right-side modifiers are extended keys', () {
    expect(WindowsKeyMap.keys[SemanticKey.delete]!.extended, isTrue);
    expect(WindowsKeyMap.keys[SemanticKey.arrowLeft]!.extended, isTrue);
    expect(WindowsKeyMap.modifiers[ModifierKey.rightCtrl]!.extended, isTrue);
    expect(WindowsKeyMap.modifiers[ModifierKey.rightAlt]!.extended, isTrue);
  });
}

