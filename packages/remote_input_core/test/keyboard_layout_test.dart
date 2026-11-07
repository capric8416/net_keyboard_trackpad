import 'package:remote_input_core/remote_input_core.dart';
import 'package:test/test.dart';

void main() {
  test('standard layout has five rows and exactly 64 unique keys', () {
    expect(Standard64Layout.rows, hasLength(5));
    expect(Standard64Layout.keys, hasLength(64));
    expect(Standard64Layout.keys.map((key) => key.id).toSet(), hasLength(64));
    expect(Standard64Layout.validate, returnsNormally);
    expect(
      Standard64Layout.keys
          .where((key) => key.kind == KeyKind.remote)
          .expand((key) => [key.semanticKey, key.fnSemanticKey])
          .whereType<SemanticKey>()
          .toSet(),
      hasLength(SemanticKey.values.length),
    );
  });

  test('modifier set toggles each modifier independently', () {
    const empty = ModifierSet.empty();
    final shifted = empty.toggle(ModifierKey.leftShift);
    expect(shifted.contains(ModifierKey.leftShift), isTrue);
    expect(shifted.contains(ModifierKey.rightShift), isFalse);
    expect(shifted.toggle(ModifierKey.leftShift), empty);
  });

  test('platform-neutral modifier label uses Meta', () {
    final meta = Standard64Layout.keys.singleWhere(
      (key) => key.modifier == ModifierKey.leftMeta,
    );
    expect(meta.label, 'Meta');
  });
}
