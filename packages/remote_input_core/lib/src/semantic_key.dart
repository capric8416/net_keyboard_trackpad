/// Platform-neutral key identifiers sent over the wire.
///
/// These names are intentionally independent from platform key codes. Published
/// protobuf enum numbers must remain stable when a controlled-device platform
/// implementation changes.
enum SemanticKey {
  escape,
  f1,
  f2,
  f3,
  f4,
  f5,
  f6,
  f7,
  f8,
  f9,
  f10,
  f11,
  f12,
  printScreen,
  delete,
  home,
  backquote,
  digit1,
  digit2,
  digit3,
  digit4,
  digit5,
  digit6,
  digit7,
  digit8,
  digit9,
  digit0,
  minus,
  equal,
  backspace,
  pageUp,
  tab,
  keyQ,
  keyW,
  keyE,
  keyR,
  keyT,
  keyY,
  keyU,
  keyI,
  keyO,
  keyP,
  bracketLeft,
  bracketRight,
  backslash,
  pageDown,
  capsLock,
  keyA,
  keyS,
  keyD,
  keyF,
  keyG,
  keyH,
  keyJ,
  keyK,
  keyL,
  semicolon,
  quote,
  enter,
  keyZ,
  keyX,
  keyC,
  keyV,
  keyB,
  keyN,
  keyM,
  comma,
  period,
  slash,
  arrowUp,
  end,
  space,
  menu,
  arrowLeft,
  arrowDown,
  arrowRight,
}

enum ModifierKey {
  leftCtrl(1 << 0),
  rightCtrl(1 << 1),
  leftAlt(1 << 2),
  rightAlt(1 << 3),
  leftShift(1 << 4),
  rightShift(1 << 5),
  leftMeta(1 << 6),
  rightMeta(1 << 7);

  const ModifierKey(this.bit);

  final int bit;
}

enum LocalKeyAction { fnLayer }

/// A complete and atomic remote keystroke.
final class KeyStroke {
  const KeyStroke({required this.key, required this.modifierBits});

  final SemanticKey key;
  final int modifierBits;

  @override
  bool operator ==(Object other) =>
      other is KeyStroke &&
      other.key == key &&
      other.modifierBits == modifierBits;

  @override
  int get hashCode => Object.hash(key, modifierBits);
}
