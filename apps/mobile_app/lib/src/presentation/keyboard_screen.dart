import 'package:flutter/material.dart';
import 'package:remote_input_core/remote_input_core.dart';

import '../application/keyboard_controller.dart';
import 'widgets/keyboard_key_view.dart';
import 'widgets/voice_input_button.dart';
import 'widgets/trackpad_view.dart';

class KeyboardScreen extends StatelessWidget {
  const KeyboardScreen({
    required this.controller,
    required this.onManageDevices,
    super.key,
  });

  final KeyboardController controller;
  final VoidCallback onManageDevices;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final error = controller.lastError;
      final voicePhase = controller.voiceState.phase;
      return Scaffold(
        body: Stack(
          children: [
            SafeArea(
              minimum: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _StatusBar(
                    controller: controller,
                    onManageDevices: onManageDevices,
                  ),
                  if (error != null)
                    MaterialBanner(
                      content: Text(error),
                      actions: [
                        TextButton(
                          onPressed: controller.dismissError,
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: OrientationBuilder(
                      builder: (context, orientation) => Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: orientation == Orientation.landscape
                                ? Column(
                                    children: [
                                      for (final row in Standard64Layout.rows)
                                        Expanded(
                                          child: _KeyboardRow(
                                            keys: row,
                                            controller: controller,
                                          ),
                                        ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Expanded(
                                        child: _KeyboardHalf(
                                          left: true,
                                          controller: controller,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: _KeyboardHalf(
                                          left: false,
                                          controller: controller,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TrackpadView(controller: controller),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (voicePhase == VoiceInputPhase.reviewing ||
                voicePhase == VoiceInputPhase.submitting)
              _VoiceReviewOverlay(controller: controller),
          ],
        ),
      );
    },
  );
}

class _VoiceReviewOverlay extends StatelessWidget {
  const _VoiceReviewOverlay({required this.controller});

  final KeyboardController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.voiceState;
    final submitting = state.phase == VoiceInputPhase.submitting;
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 360),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('确认语音输入', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('确认后将输入到当前激活窗口。'),
                  const SizedBox(height: 12),
                  Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(state.reviewText ?? ''),
                      ),
                    ),
                  ),
                  if (state.message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.message!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: submitting
                            ? null
                            : controller.cancelVoiceText,
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: submitting || !controller.canSend
                            ? null
                            : controller.confirmVoiceText,
                        child: submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('确认输入'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller, required this.onManageDevices});

  final KeyboardController controller;
  final VoidCallback onManageDevices;

  @override
  Widget build(BuildContext context) {
    final status = controller.connectionStatus;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Icon(
            status.canSend ? Icons.lan : Icons.link_off,
            color: status.canSend
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.message ?? status.phase.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: onManageDevices,
            icon: const Icon(Icons.devices),
            label: const Text('受控端'),
          ),
          const SizedBox(width: 8),
          VoiceInputButton(controller: controller),
        ],
      ),
    );
  }
}

class _KeyboardRow extends StatelessWidget {
  const _KeyboardRow({required this.keys, required this.controller});

  final KeyboardRow keys;
  final KeyboardController controller;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final key in keys)
        Expanded(
          flex: (key.width * 100).round(),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: KeyboardKeyView(keySpec: key, controller: controller),
          ),
        ),
    ],
  );
}

class _KeyboardHalf extends StatelessWidget {
  const _KeyboardHalf({required this.left, required this.controller});

  final bool left;
  final KeyboardController controller;

  static const _leftIds = {
    'escape', 'backquote', 'digit_1', 'digit_2', 'digit_3', 'digit_4',
    'digit_5', 'digit_6', 'tab', 'key_q', 'key_w', 'key_e', 'key_r', 'key_t',
    'caps_lock', 'key_a', 'key_s', 'key_d', 'key_f', 'key_g', 'left_shift',
    'key_z', 'key_x', 'key_c', 'key_v', 'key_b', 'left_ctrl', 'left_meta',
    'left_alt',
  };

  static const _rightIds = {
    'digit_7', 'digit_8', 'digit_9', 'digit_0', 'minus', 'equal', 'backspace',
    'key_y', 'key_u', 'key_i', 'key_o', 'key_p', 'bracket_left',
    'bracket_right', 'backslash', 'key_h', 'key_j', 'key_k', 'key_l',
    'semicolon', 'quote', 'enter', 'key_n', 'key_m', 'comma', 'period',
    'slash', 'right_shift', 'arrow_up', 'right_alt', 'fn', 'arrow_left',
    'arrow_down', 'arrow_right',
  };

  static const _leftSpace = KeyboardKeySpec.remote(
    'left_space',
    '',
    SemanticKey.space,
    width: 3.125,
  );
  static const _rightSpace = KeyboardKeySpec.remote(
    'right_space',
    '',
    SemanticKey.space,
    width: 3.125,
  );

  @override
  Widget build(BuildContext context) {
    final keys = Standard64Layout.rows
        .map(
          (row) => row
              .where((key) => (left ? _leftIds : _rightIds).contains(key.id))
              .toList(),
        )
        .toList();
    final space = left ? _leftSpace : _rightSpace;
    if (left) {
      keys[2].add(
        Standard64Layout.keys.firstWhere((key) => key.id == 'enter'),
      );
      keys[4].add(space);
    } else {
      keys[4].insert(0, space);
    }

    return Column(
      children: [
        for (final row in keys)
          Expanded(child: _KeyboardRow(keys: row, controller: controller)),
      ],
    );
  }
}
