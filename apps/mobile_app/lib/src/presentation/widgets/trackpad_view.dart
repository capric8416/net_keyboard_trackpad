import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remote_input_protocol/remote_input_protocol.dart';

import '../../application/keyboard_controller.dart';

class TrackpadView extends StatefulWidget {
  const TrackpadView({required this.controller, super.key});
  final KeyboardController controller;

  @override
  State<TrackpadView> createState() => _TrackpadViewState();
}

class _TrackpadViewState extends State<TrackpadView> {
  final Map<int, Offset> _pointers = {};
  Timer? _tapTimer;
  DateTime? _firstTapAt;
  Offset? _firstTapPosition;
  Offset? _previousCentroid;
  bool _moved = false;
  bool _multiGesture = false;
  bool _doubleTapRecognized = false;
  int _maxPointerCount = 0;

  void _down(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;
    if (_pointers.length > _maxPointerCount) {
      _maxPointerCount = _pointers.length;
    }
    _previousCentroid = _centroid;
    if (_pointers.length == 1) {
      _moved = false;
      _multiGesture = false;
      _doubleTapRecognized = false;
      final now = DateTime.now();
      final doubleTap =
          _firstTapAt != null &&
          now.difference(_firstTapAt!) < const Duration(milliseconds: 320) &&
          (_firstTapPosition! - event.localPosition).distance < 36;
      if (doubleTap) {
        _tapTimer?.cancel();
        _click(PointerButton.POINTER_BUTTON_LEFT);
        _click(PointerButton.POINTER_BUTTON_LEFT);
        _doubleTapRecognized = true;
        _firstTapAt = null;
      }
    } else {
      _multiGesture = true;
      _tapTimer?.cancel();
      if (_pointers.length > 2) _moved = true;
    }
  }

  void _move(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    final before = _previousCentroid ?? _centroid;
    _pointers[event.pointer] = event.localPosition;
    final after = _centroid;
    final delta = after - before;
    _previousCentroid = after;
    if (_maxPointerCount > 2) return;
    if (_pointers.length == 1) {
      if (delta.distance > 1) _moved = true;
      _send(
        PointerInput(
          deltaX: (delta.dx * 1.45).round(),
          deltaY: (delta.dy * 1.45).round(),
        ),
      );
      return;
    }
    if (_pointers.length == 2) {
      if (delta.distance > 1.2) _moved = true;
      if (delta.distance > 1.2) {
        if (delta.dy.abs() >= delta.dx.abs()) {
          _send(PointerInput(wheelDelta: (-delta.dy * 8).round()));
        } else {
          _send(PointerInput(horizontalWheelDelta: (delta.dx * 8).round()));
        }
      }
      return;
    }
  }

  void _up(PointerUpEvent event) {
    final count = _pointers.length;
    if (count == 1) {
      if (!_moved && !_multiGesture && !_doubleTapRecognized) {
        _firstTapAt = DateTime.now();
        _firstTapPosition = event.localPosition;
        _tapTimer?.cancel();
        _tapTimer = Timer(const Duration(milliseconds: 330), () {
          _click(PointerButton.POINTER_BUTTON_LEFT);
          _firstTapAt = null;
        });
      }
      _doubleTapRecognized = false;
    } else if (count == 2 && _maxPointerCount == 2 && !_moved) {
      _click(PointerButton.POINTER_BUTTON_RIGHT);
      _moved = true;
    }
    _pointers.remove(event.pointer);
    if (_pointers.isEmpty) {
      _previousCentroid = null;
      _multiGesture = false;
      _moved = false;
      _maxPointerCount = 0;
    } else {
      _previousCentroid = _centroid;
    }
  }

  void _cancel(PointerCancelEvent event) {
    _pointers.clear();
    _multiGesture = false;
    _doubleTapRecognized = false;
    _maxPointerCount = 0;
  }

  Offset get _centroid {
    if (_pointers.isEmpty) return Offset.zero;
    var result = Offset.zero;
    for (final position in _pointers.values) result += position;
    return result / _pointers.length.toDouble();
  }

  void _click(PointerButton button) {
    _button(button, true);
    _button(button, false);
  }

  void _button(PointerButton button, bool down) =>
      _send(PointerInput(button: button, buttonDown: down));

  void _send(PointerInput input) {
    if (widget.controller.canSend) widget.controller.sendPointer(input);
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _down,
    onPointerMove: _move,
    onPointerUp: _up,
    onPointerCancel: _cancel,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 36),
            SizedBox(height: 8),
            Text('触控板'),
            Text(
              '单击 · 双击 · 双指右键 · 双指横向/纵向滚动',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}
