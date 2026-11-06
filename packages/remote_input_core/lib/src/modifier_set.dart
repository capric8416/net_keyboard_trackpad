import 'semantic_key.dart';

final class ModifierSet {
  const ModifierSet._(this.bits);

  const ModifierSet.empty() : bits = 0;

  factory ModifierSet.fromBits(int bits) {
    if (bits < 0 || bits & ~validMask != 0) {
      throw ArgumentError.value(bits, 'bits', 'contains unknown modifiers');
    }
    return ModifierSet._(bits);
  }

  static final int validMask = ModifierKey.values.fold(
    0,
    (value, modifier) => value | modifier.bit,
  );

  final int bits;

  bool contains(ModifierKey modifier) => bits & modifier.bit != 0;

  bool get isEmpty => bits == 0;

  ModifierSet toggle(ModifierKey modifier) =>
      ModifierSet._(bits ^ modifier.bit);

  ModifierSet add(ModifierKey modifier) => ModifierSet._(bits | modifier.bit);

  ModifierSet remove(ModifierKey modifier) =>
      ModifierSet._(bits & ~modifier.bit);

  Iterable<ModifierKey> get selected sync* {
    for (final modifier in ModifierKey.values) {
      if (contains(modifier)) yield modifier;
    }
  }

  @override
  bool operator ==(Object other) => other is ModifierSet && other.bits == bits;

  @override
  int get hashCode => bits.hashCode;

  @override
  String toString() =>
      'ModifierSet(${selected.map((item) => item.name).join(', ')})';
}
