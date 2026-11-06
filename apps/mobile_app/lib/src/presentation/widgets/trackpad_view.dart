import 'dart:async';
import 'dart:math' as math;

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
  double? _previousSpan;
  Offset _threeFingerTravel = Offset.zero;
  bool _dragging = false;
  bool _moved = false;
  bool _multiGesture = false;
  bool _threeFingerSent = false;

  void _down(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;
    _previousCentroid = _centroid;
    if (_pointers.length == 1) {
      _moved = false;
      _multiGesture = false;
      final now = DateTime.now();
      final doubleTap =
          _firstTapAt != null &&
          now.difference(_firstTapAt!) < const Duration(milliseconds: 320) &&
          (_firstTapPosition! - event.localPosition).distance < 36;
      if (doubleTap) {
        _tapTimer?.cancel();
        _click(PointerButton.POINTER_BUTTON_LEFT);
        _button(PointerButton.POINTER_BUTTON_LEFT, true);
        _dragging = true;
        _firstTapAt = null;
      }
    } else {
      _multiGesture = true;
      _tapTimer?.cancel();
      _previousSpan = _span;
      if (_pointers.length == 3) {
        _threeFingerTravel = Offset.zero;
        _threeFingerSent = false;
      }
    }
  }

  void _move(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    final before = _previousCentroid ?? _centroid;
    _pointers[event.pointer] = event.localPosition;
    final after = _centroid;
    final delta = after - before;
    _previousCentroid = after;
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
      final span = _span;
      final oldSpan = _previousSpan ?? span;
      final spanDelta = span - oldSpan;
      _previousSpan = span;
      if (spanDelta.abs() > 5) {
        _send(
          PointerInput(
            gesture: spanDelta > 0
                ? SystemGesture.SYSTEM_GESTURE_ZOOM_IN
                : SystemGesture.SYSTEM_GESTURE_ZOOM_OUT,
          ),
        );
      } else if (delta.distance > 1.2) {
        if (delta.dy.abs() >= delta.dx.abs()) {
          _send(PointerInput(wheelDelta: (-delta.dy * 8).round()));
        } else {
          _send(PointerInput(horizontalWheelDelta: (delta.dx * 8).round()));
        }
      }
      return;
    }
    if (_pointers.length == 3 && !_threeFingerSent) {
      _threeFingerTravel += delta;
      if (_threeFingerTravel.distance > 60) {
        final vertical =
            _threeFingerTravel.dy.abs() > _threeFingerTravel.dx.abs();
        final gesture = vertical
            ? (_threeFingerTravel.dy < 0
                  ? SystemGesture.SYSTEM_GESTURE_TASK_VIEW
                  : SystemGesture.SYSTEM_GESTURE_SHOW_DESKTOP)
            : (_threeFingerTravel.dx < 0
                  ? SystemGesture.SYSTEM_GESTURE_SWITCH_APP_NEXT
                  : SystemGesture.SYSTEM_GESTURE_SWITCH_APP_PREVIOUS);
        _send(PointerInput(gesture: gesture));
        _threeFingerSent = true;
      }
    }
  }

  void _up(PointerUpEvent event) {
    final count = _pointers.length;
    if (count == 1) {
      if (_dragging) {
        _button(PointerButton.POINTER_BUTTON_LEFT, false);
      } else if (!_moved && !_multiGesture) {
        _firstTapAt = DateTime.now();
        _firstTapPosition = event.localPosition;
        _tapTimer?.cancel();
        _tapTimer = Timer(const Duration(milliseconds: 330), () {
          _click(PointerButton.POINTER_BUTTON_LEFT);
          _firstTapAt = null;
        });
      }
      _dragging = false;
    } else if (count == 2 && !_moved) {
      _click(PointerButton.POINTER_BUTTON_RIGHT);
      _moved = true;
    }
    _pointers.remove(event.pointer);
    if (_pointers.isEmpty) {
      _previousCentroid = null;
      _previousSpan = null;
      _multiGesture = false;
      _moved = false;
    } else {
      _previousCentroid = _centroid;
      _previousSpan = _span;
    }
  }

  void _cancel(PointerCancelEvent event) {
    if (_dragging) _button(PointerButton.POINTER_BUTTON_LEFT, false);
    _pointers.clear();
    _dragging = false;
    _multiGesture = false;
  }

  Offset get _centroid {
    if (_pointers.isEmpty) return Offset.zero;
    var result = Offset.zero;
    for (final position in _pointers.values) result += position;
    return result / _pointers.length.toDouble();
  }

  double get _span {
    if (_pointers.length < 2) return 0;
    final points = _pointers.values.toList(growable: false);
    return math.max(0, (points[0] - points[1]).distance);
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
    if (_dragging) _button(PointerButton.POINTER_BUTTON_LEFT, false);
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
              '单指轻点左击 · 双指滚动/缩放 · 三指系统手势',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}
