import 'semantic_key.dart';

enum KeyKind { remote, modifier, local }

final class KeyboardKeySpec {
  const KeyboardKeySpec.remote(
    this.id,
    this.label,
    this.semanticKey, {
    this.shiftLabel,
    this.fnLabel,
    this.fnSemanticKey,
    this.width = 1,
    this.repeatable = false,
  }) : kind = KeyKind.remote,
       modifier = null,
       fnModifier = null,
       localAction = null;

  const KeyboardKeySpec.modifier(
    this.id,
    this.label,
    this.modifier, {
    this.fnLabel,
    this.fnModifier,
    this.width = 1,
  }) : kind = KeyKind.modifier,
       semanticKey = null,
       fnSemanticKey = null,
       shiftLabel = null,
       localAction = null,
       repeatable = false;

  const KeyboardKeySpec.local(
    this.id,
    this.label,
    this.localAction, {
    this.width = 1,
  }) : kind = KeyKind.local,
       semanticKey = null,
       fnSemanticKey = null,
       shiftLabel = null,
       fnLabel = null,
       modifier = null,
       fnModifier = null,
       repeatable = false;

  final String id;
  final String label;
  final String? shiftLabel;
  final String? fnLabel;
  final KeyKind kind;
  final SemanticKey? semanticKey;
  final SemanticKey? fnSemanticKey;
  final ModifierKey? modifier;
  final ModifierKey? fnModifier;
  final LocalKeyAction? localAction;
  final double width;
  final bool repeatable;
}

typedef KeyboardRow = List<KeyboardKeySpec>;

/// Product-defined ANSI-US compact 64-key matrix with a sticky Fn layer.
abstract final class Standard64Layout {
  static const rows = <KeyboardRow>[
    [
      KeyboardKeySpec.remote('escape', 'Esc', SemanticKey.escape),
      KeyboardKeySpec.remote(
        'backquote',
        '`',
        SemanticKey.backquote,
        shiftLabel: '~',
      ),
      KeyboardKeySpec.remote(
        'digit_1',
        '1',
        SemanticKey.digit1,
        shiftLabel: '!',
        fnLabel: 'F1',
        fnSemanticKey: SemanticKey.f1,
      ),
      KeyboardKeySpec.remote(
        'digit_2',
        '2',
        SemanticKey.digit2,
        shiftLabel: '@',
        fnLabel: 'F2',
        fnSemanticKey: SemanticKey.f2,
      ),
      KeyboardKeySpec.remote(
        'digit_3',
        '3',
        SemanticKey.digit3,
        shiftLabel: '#',
        fnLabel: 'F3',
        fnSemanticKey: SemanticKey.f3,
      ),
      KeyboardKeySpec.remote(
        'digit_4',
        '4',
        SemanticKey.digit4,
        shiftLabel: r'$',
        fnLabel: 'F4',
        fnSemanticKey: SemanticKey.f4,
      ),
      KeyboardKeySpec.remote(
        'digit_5',
        '5',
        SemanticKey.digit5,
        shiftLabel: '%',
        fnLabel: 'F5',
        fnSemanticKey: SemanticKey.f5,
      ),
      KeyboardKeySpec.remote(
        'digit_6',
        '6',
        SemanticKey.digit6,
        shiftLabel: '^',
        fnLabel: 'F6',
        fnSemanticKey: SemanticKey.f6,
      ),
      KeyboardKeySpec.remote(
        'digit_7',
        '7',
        SemanticKey.digit7,
        shiftLabel: '&',
        fnLabel: 'F7',
        fnSemanticKey: SemanticKey.f7,
      ),
      KeyboardKeySpec.remote(
        'digit_8',
        '8',
        SemanticKey.digit8,
        shiftLabel: '*',
        fnLabel: 'F8',
        fnSemanticKey: SemanticKey.f8,
      ),
      KeyboardKeySpec.remote(
        'digit_9',
        '9',
        SemanticKey.digit9,
        shiftLabel: '(',
        fnLabel: 'F9',
        fnSemanticKey: SemanticKey.f9,
      ),
      KeyboardKeySpec.remote(
        'digit_0',
        '0',
        SemanticKey.digit0,
        shiftLabel: ')',
        fnLabel: 'F10',
        fnSemanticKey: SemanticKey.f10,
      ),
      KeyboardKeySpec.remote(
        'minus',
        '-',
        SemanticKey.minus,
        shiftLabel: '_',
        fnLabel: 'F11',
        fnSemanticKey: SemanticKey.f11,
      ),
      KeyboardKeySpec.remote(
        'equal',
        '=',
        SemanticKey.equal,
        shiftLabel: '+',
        fnLabel: 'F12',
        fnSemanticKey: SemanticKey.f12,
      ),
      KeyboardKeySpec.remote(
        'backspace',
        'Backspace',
        SemanticKey.backspace,
        fnLabel: 'Del',
        fnSemanticKey: SemanticKey.delete,
        width: 2,
        repeatable: true,
      ),
    ],
    [
      KeyboardKeySpec.remote('tab', 'Tab', SemanticKey.tab, width: 1.5),
      KeyboardKeySpec.remote('key_q', 'Q', SemanticKey.keyQ),
      KeyboardKeySpec.remote('key_w', 'W', SemanticKey.keyW),
      KeyboardKeySpec.remote('key_e', 'E', SemanticKey.keyE),
      KeyboardKeySpec.remote('key_r', 'R', SemanticKey.keyR),
      KeyboardKeySpec.remote('key_t', 'T', SemanticKey.keyT),
      KeyboardKeySpec.remote('key_y', 'Y', SemanticKey.keyY),
      KeyboardKeySpec.remote('key_u', 'U', SemanticKey.keyU),
      KeyboardKeySpec.remote('key_i', 'I', SemanticKey.keyI),
      KeyboardKeySpec.remote('key_o', 'O', SemanticKey.keyO),
      KeyboardKeySpec.remote(
        'key_p',
        'P',
        SemanticKey.keyP,
        fnLabel: 'PrtSc',
        fnSemanticKey: SemanticKey.printScreen,
      ),
      KeyboardKeySpec.remote(
        'bracket_left',
        '[',
        SemanticKey.bracketLeft,
        shiftLabel: '{',
        fnLabel: 'Home',
        fnSemanticKey: SemanticKey.home,
      ),
      KeyboardKeySpec.remote(
        'bracket_right',
        ']',
        SemanticKey.bracketRight,
        shiftLabel: '}',
        fnLabel: 'End',
        fnSemanticKey: SemanticKey.end,
      ),
      KeyboardKeySpec.remote(
        'backslash',
        '\\',
        SemanticKey.backslash,
        shiftLabel: '|',
        fnLabel: 'Menu',
        fnSemanticKey: SemanticKey.menu,
        width: 1.5,
      ),
    ],
    [
      KeyboardKeySpec.remote(
        'caps_lock',
        'Caps',
        SemanticKey.capsLock,
        width: 1.75,
      ),
      KeyboardKeySpec.remote('key_a', 'A', SemanticKey.keyA),
      KeyboardKeySpec.remote('key_s', 'S', SemanticKey.keyS),
      KeyboardKeySpec.remote('key_d', 'D', SemanticKey.keyD),
      KeyboardKeySpec.remote('key_f', 'F', SemanticKey.keyF),
      KeyboardKeySpec.remote('key_g', 'G', SemanticKey.keyG),
      KeyboardKeySpec.remote('key_h', 'H', SemanticKey.keyH),
      KeyboardKeySpec.remote('key_j', 'J', SemanticKey.keyJ),
      KeyboardKeySpec.remote('key_k', 'K', SemanticKey.keyK),
      KeyboardKeySpec.remote('key_l', 'L', SemanticKey.keyL),
      KeyboardKeySpec.remote(
        'semicolon',
        ';',
        SemanticKey.semicolon,
        shiftLabel: ':',
      ),
      KeyboardKeySpec.remote('quote', "'", SemanticKey.quote, shiftLabel: '"'),
      KeyboardKeySpec.remote('enter', 'Enter', SemanticKey.enter, width: 2.25),
    ],
    [
      KeyboardKeySpec.modifier(
        'left_shift',
        'Shift',
        ModifierKey.leftShift,
        width: 2.25,
      ),
      KeyboardKeySpec.remote('key_z', 'Z', SemanticKey.keyZ),
      KeyboardKeySpec.remote('key_x', 'X', SemanticKey.keyX),
      KeyboardKeySpec.remote('key_c', 'C', SemanticKey.keyC),
      KeyboardKeySpec.remote('key_v', 'V', SemanticKey.keyV),
      KeyboardKeySpec.remote('key_b', 'B', SemanticKey.keyB),
      KeyboardKeySpec.remote('key_n', 'N', SemanticKey.keyN),
      KeyboardKeySpec.remote('key_m', 'M', SemanticKey.keyM),
      KeyboardKeySpec.remote('comma', ',', SemanticKey.comma, shiftLabel: '<'),
      KeyboardKeySpec.remote(
        'period',
        '.',
        SemanticKey.period,
        shiftLabel: '>',
      ),
      KeyboardKeySpec.remote('slash', '/', SemanticKey.slash, shiftLabel: '?'),
      KeyboardKeySpec.modifier(
        'right_shift',
        'Shift',
        ModifierKey.rightShift,
        width: 1.75,
      ),
      KeyboardKeySpec.remote(
        'arrow_up',
        '↑',
        SemanticKey.arrowUp,
        fnLabel: 'PgUp',
        fnSemanticKey: SemanticKey.pageUp,
        repeatable: true,
      ),
    ],
    [
      KeyboardKeySpec.modifier(
        'left_ctrl',
        'Ctrl',
        ModifierKey.leftCtrl,
        fnLabel: 'RCtrl',
        fnModifier: ModifierKey.rightCtrl,
      ),
      KeyboardKeySpec.modifier('left_meta', 'Win', ModifierKey.leftMeta),
      KeyboardKeySpec.modifier('left_alt', 'Alt', ModifierKey.leftAlt),
      KeyboardKeySpec.remote('space', '', SemanticKey.space, width: 6.25),
      KeyboardKeySpec.modifier('right_alt', 'Alt', ModifierKey.rightAlt),
      KeyboardKeySpec.local('fn', 'Fn', LocalKeyAction.fnLayer),
      KeyboardKeySpec.remote(
        'arrow_left',
        '←',
        SemanticKey.arrowLeft,
        repeatable: true,
      ),
      KeyboardKeySpec.remote(
        'arrow_down',
        '↓',
        SemanticKey.arrowDown,
        fnLabel: 'PgDn',
        fnSemanticKey: SemanticKey.pageDown,
        repeatable: true,
      ),
      KeyboardKeySpec.remote(
        'arrow_right',
        '→',
        SemanticKey.arrowRight,
        repeatable: true,
      ),
    ],
  ];

  static List<KeyboardKeySpec> get keys =>
      rows.expand((row) => row).toList(growable: false);

  static void validate() {
    final allKeys = keys;
    if (allKeys.length != 64) {
      throw StateError(
        'Standard64Layout has ${allKeys.length} keys, expected 64',
      );
    }
    final ids = allKeys.map((key) => key.id).toSet();
    if (ids.length != allKeys.length) {
      throw StateError('Standard64Layout contains duplicate key ids');
    }
    final remoteKeys = allKeys
        .where((key) => key.kind == KeyKind.remote)
        .expand((key) => [key.semanticKey!, ?key.fnSemanticKey])
        .toSet();
    if (remoteKeys.length != SemanticKey.values.length ||
        !remoteKeys.containsAll(SemanticKey.values)) {
      throw StateError('Standard64Layout does not map every SemanticKey once');
    }
    for (final key in allKeys) {
      if (key.width <= 0) {
        throw StateError('${key.id} has an invalid width');
      }
    }
  }
}
