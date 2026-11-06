import 'package:remote_input_core/remote_input_core.dart';

final class WindowsKeyMapping {
  const WindowsKeyMapping(this.scanCode, {this.extended = false});

  final int scanCode;
  final bool extended;
}

/// Set-1 scan codes consumed by Win32 `SendInput` with KEYEVENTF_SCANCODE.
abstract final class WindowsKeyMap {
  static const keys = <SemanticKey, WindowsKeyMapping>{
    SemanticKey.escape: WindowsKeyMapping(0x01),
    SemanticKey.f1: WindowsKeyMapping(0x3b),
    SemanticKey.f2: WindowsKeyMapping(0x3c),
    SemanticKey.f3: WindowsKeyMapping(0x3d),
    SemanticKey.f4: WindowsKeyMapping(0x3e),
    SemanticKey.f5: WindowsKeyMapping(0x3f),
    SemanticKey.f6: WindowsKeyMapping(0x40),
    SemanticKey.f7: WindowsKeyMapping(0x41),
    SemanticKey.f8: WindowsKeyMapping(0x42),
    SemanticKey.f9: WindowsKeyMapping(0x43),
    SemanticKey.f10: WindowsKeyMapping(0x44),
    SemanticKey.f11: WindowsKeyMapping(0x57),
    SemanticKey.f12: WindowsKeyMapping(0x58),
    SemanticKey.printScreen: WindowsKeyMapping(0x37, extended: true),
    SemanticKey.delete: WindowsKeyMapping(0x53, extended: true),
    SemanticKey.home: WindowsKeyMapping(0x47, extended: true),
    SemanticKey.backquote: WindowsKeyMapping(0x29),
    SemanticKey.digit1: WindowsKeyMapping(0x02),
    SemanticKey.digit2: WindowsKeyMapping(0x03),
    SemanticKey.digit3: WindowsKeyMapping(0x04),
    SemanticKey.digit4: WindowsKeyMapping(0x05),
    SemanticKey.digit5: WindowsKeyMapping(0x06),
    SemanticKey.digit6: WindowsKeyMapping(0x07),
    SemanticKey.digit7: WindowsKeyMapping(0x08),
    SemanticKey.digit8: WindowsKeyMapping(0x09),
    SemanticKey.digit9: WindowsKeyMapping(0x0a),
    SemanticKey.digit0: WindowsKeyMapping(0x0b),
    SemanticKey.minus: WindowsKeyMapping(0x0c),
    SemanticKey.equal: WindowsKeyMapping(0x0d),
    SemanticKey.backspace: WindowsKeyMapping(0x0e),
    SemanticKey.pageUp: WindowsKeyMapping(0x49, extended: true),
    SemanticKey.tab: WindowsKeyMapping(0x0f),
    SemanticKey.keyQ: WindowsKeyMapping(0x10),
    SemanticKey.keyW: WindowsKeyMapping(0x11),
    SemanticKey.keyE: WindowsKeyMapping(0x12),
    SemanticKey.keyR: WindowsKeyMapping(0x13),
    SemanticKey.keyT: WindowsKeyMapping(0x14),
    SemanticKey.keyY: WindowsKeyMapping(0x15),
    SemanticKey.keyU: WindowsKeyMapping(0x16),
    SemanticKey.keyI: WindowsKeyMapping(0x17),
    SemanticKey.keyO: WindowsKeyMapping(0x18),
    SemanticKey.keyP: WindowsKeyMapping(0x19),
    SemanticKey.bracketLeft: WindowsKeyMapping(0x1a),
    SemanticKey.bracketRight: WindowsKeyMapping(0x1b),
    SemanticKey.backslash: WindowsKeyMapping(0x2b),
    SemanticKey.pageDown: WindowsKeyMapping(0x51, extended: true),
    SemanticKey.capsLock: WindowsKeyMapping(0x3a),
    SemanticKey.keyA: WindowsKeyMapping(0x1e),
    SemanticKey.keyS: WindowsKeyMapping(0x1f),
    SemanticKey.keyD: WindowsKeyMapping(0x20),
    SemanticKey.keyF: WindowsKeyMapping(0x21),
    SemanticKey.keyG: WindowsKeyMapping(0x22),
    SemanticKey.keyH: WindowsKeyMapping(0x23),
    SemanticKey.keyJ: WindowsKeyMapping(0x24),
    SemanticKey.keyK: WindowsKeyMapping(0x25),
    SemanticKey.keyL: WindowsKeyMapping(0x26),
    SemanticKey.semicolon: WindowsKeyMapping(0x27),
    SemanticKey.quote: WindowsKeyMapping(0x28),
    SemanticKey.enter: WindowsKeyMapping(0x1c),
    SemanticKey.keyZ: WindowsKeyMapping(0x2c),
    SemanticKey.keyX: WindowsKeyMapping(0x2d),
    SemanticKey.keyC: WindowsKeyMapping(0x2e),
    SemanticKey.keyV: WindowsKeyMapping(0x2f),
    SemanticKey.keyB: WindowsKeyMapping(0x30),
    SemanticKey.keyN: WindowsKeyMapping(0x31),
    SemanticKey.keyM: WindowsKeyMapping(0x32),
    SemanticKey.comma: WindowsKeyMapping(0x33),
    SemanticKey.period: WindowsKeyMapping(0x34),
    SemanticKey.slash: WindowsKeyMapping(0x35),
    SemanticKey.arrowUp: WindowsKeyMapping(0x48, extended: true),
    SemanticKey.end: WindowsKeyMapping(0x4f, extended: true),
    SemanticKey.space: WindowsKeyMapping(0x39),
    SemanticKey.menu: WindowsKeyMapping(0x5d, extended: true),
    SemanticKey.arrowLeft: WindowsKeyMapping(0x4b, extended: true),
    SemanticKey.arrowDown: WindowsKeyMapping(0x50, extended: true),
    SemanticKey.arrowRight: WindowsKeyMapping(0x4d, extended: true),
  };

  static const modifiers = <ModifierKey, WindowsKeyMapping>{
    ModifierKey.leftCtrl: WindowsKeyMapping(0x1d),
    ModifierKey.rightCtrl: WindowsKeyMapping(0x1d, extended: true),
    ModifierKey.leftAlt: WindowsKeyMapping(0x38),
    ModifierKey.rightAlt: WindowsKeyMapping(0x38, extended: true),
    ModifierKey.leftShift: WindowsKeyMapping(0x2a),
    ModifierKey.rightShift: WindowsKeyMapping(0x36),
    ModifierKey.leftMeta: WindowsKeyMapping(0x5b, extended: true),
    ModifierKey.rightMeta: WindowsKeyMapping(0x5c, extended: true),
  };

  static void validate() {
    if (keys.length != SemanticKey.values.length ||
        !keys.keys.toSet().containsAll(SemanticKey.values)) {
      throw StateError('Windows key map does not cover every SemanticKey');
    }
    if (modifiers.length != ModifierKey.values.length ||
        !modifiers.keys.toSet().containsAll(ModifierKey.values)) {
      throw StateError('Windows key map does not cover every ModifierKey');
    }
  }
}
