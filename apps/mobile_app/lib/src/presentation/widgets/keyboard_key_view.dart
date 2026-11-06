import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:remote_input_core/remote_input_core.dart';

import '../../application/keyboard_controller.dart';

class KeyboardKeyView extends StatefulWidget {
  const KeyboardKeyView({
    required this.keySpec,
    required this.controller,
    super.key,
  });

  final KeyboardKeySpec keySpec;
  final KeyboardController controller;

  @override
  State<KeyboardKeyView> createState() => _KeyboardKeyViewState();
}

class _KeyboardKeyViewState extends State<KeyboardKeyView> {
  Timer? _delayTimer;
  Timer? _repeatTimer;
  bool _pressed = false;

  bool get _selected {
    final key = widget.keySpec;
    return switch (key.kind) {
      KeyKind.modifier => widget.controller.modifiers.contains(
        widget.controller.fnSelected && key.fnModifier != null
            ? key.fnModifier!
            : key.modifier!,
      ),
      KeyKind.local => widget.controller.fnSelected,
      KeyKind.remote => false,
    };
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _pressed = true);
    if (!widget.keySpec.repeatable || !widget.controller.canSend) return;
    _delayTimer = Timer(const Duration(milliseconds: 400), () {
      _sendRemote(repeated: true);
      _repeatTimer = Timer.periodic(
        const Duration(milliseconds: 60),
        (_) => _sendRemote(repeated: true),
      );
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    final repeated = _repeatTimer != null;
    _stopRepeat();
    setState(() => _pressed = false);
    if (!repeated) _activate();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _stopRepeat();
    if (mounted) setState(() => _pressed = false);
  }

  void _stopRepeat() {
    _delayTimer?.cancel();
    _delayTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  void _activate() {
    HapticFeedback.selectionClick();
    final key = widget.keySpec;
    switch (key.kind) {
      case KeyKind.modifier:
        widget.controller.toggleModifier(
          widget.controller.fnSelected && key.fnModifier != null
              ? key.fnModifier!
              : key.modifier!,
        );
        return;
      case KeyKind.local:
        widget.controller.toggleFn();
        return;
      case KeyKind.remote:
        _sendRemote(repeated: false);
        return;
    }
  }

  void _sendRemote({required bool repeated}) {
    final spec = widget.keySpec;
    final key = widget.controller.fnSelected && spec.fnSemanticKey != null
        ? spec.fnSemanticKey
        : spec.semanticKey;
    if (key != null) {
      widget.controller.pressKey(key, repeated: repeated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final shiftActive =
        widget.controller.modifiers.contains(ModifierKey.leftShift) ||
        widget.controller.modifiers.contains(ModifierKey.rightShift);
    final label = widget.controller.fnSelected && widget.keySpec.fnLabel != null
        ? widget.keySpec.fnLabel!
        : shiftActive && widget.keySpec.shiftLabel != null
        ? widget.keySpec.shiftLabel!
        : widget.keySpec.label;
    final colors = Theme.of(context).colorScheme;
    final background = selected
        ? colors.primaryContainer
        : _pressed
        ? colors.surfaceContainerHighest
        : colors.surfaceContainer;
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
          boxShadow: _pressed
              ? null
              : const [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 2),
                    blurRadius: 2,
                  ),
                ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
