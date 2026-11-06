import '../packages/remote_input_core/lib/remote_input_core.dart';

void main() {
  Standard64Layout.validate();
  final keys = Standard64Layout.keys;
  final ids = keys.map((key) => key.id).toSet();
  if (keys.length != 64 || ids.length != 64) {
    throw StateError('64-key layout validation failed');
  }

  const empty = ModifierSet.empty();
  final selected = empty.toggle(ModifierKey.leftCtrl);
  if (!selected.contains(ModifierKey.leftCtrl) ||
      selected.contains(ModifierKey.rightCtrl) ||
      !selected.toggle(ModifierKey.leftCtrl).isEmpty) {
    throw StateError('modifier state validation failed');
  }

  print('remote_input_core validation passed: ${keys.length} unique keys');
}
