import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remote_input_core/remote_input_core.dart';

import '../../application/keyboard_controller.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({required this.controller, super.key});

  final KeyboardController controller;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  Timer? _longPressTimer;
  Timer? _maximumTimer;
  bool _recordingStarted = false;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _maximumTimer?.cancel();
    super.dispose();
  }

  void _down(PointerDownEvent event) {
    if (!widget.controller.canSend) return;
    widget.controller.setVoiceState(
      const VoiceInputState(VoiceInputPhase.pressing),
    );
    _longPressTimer = Timer(const Duration(milliseconds: 300), () async {
      _recordingStarted = true;
      HapticFeedback.mediumImpact();
      await widget.controller.startVoiceRecording(
        DateTime.now().microsecondsSinceEpoch.toString(),
      );
      if (widget.controller.voiceState.phase == VoiceInputPhase.recording) {
        _maximumTimer = Timer(const Duration(seconds: 60), () {
          if (_recordingStarted) {
            _recordingStarted = false;
            widget.controller.finishVoiceRecording();
          }
        });
      }
    });
  }

  void _up(PointerUpEvent event) {
    _longPressTimer?.cancel();
    _maximumTimer?.cancel();
    if (_recordingStarted) {
      _recordingStarted = false;
      widget.controller.finishVoiceRecording();
    } else {
      widget.controller.setVoiceState(const VoiceInputState.ready());
    }
  }

  void _cancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _maximumTimer?.cancel();
    _recordingStarted = false;
    widget.controller.cancelVoiceRecording();
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.controller.voiceState.phase;
    final recording = phase == VoiceInputPhase.recording;
    final recognizing = phase == VoiceInputPhase.recognizing;
    return Listener(
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _cancel,
      child: FilledButton.icon(
        onPressed: widget.controller.canSend ? () {} : null,
        icon: recognizing
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(recording ? Icons.mic : Icons.mic_none),
        label: Text(
          recognizing
              ? '识别中'
              : recording
              ? '松开结束录音'
              : '长按语音',
        ),
      ),
    );
  }
}
