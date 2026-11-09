import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_keyboard_desktop/main.dart';
import 'package:net_keyboard_desktop/src/application/desktop_controller.dart';
import 'package:net_keyboard_desktop/src/application/linux_input_injector.dart';

Map<String, Object> status({bool ready = false}) => {
  'backend': 'wayland',
  'ready': ready,
  'busy': false,
  'clipboard': ready,
  'message': ready ? '输入已授权' : '等待授权',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() {
    messenger.setMockMethodCallHandler(LinuxInputInjector.channel, null);
    LinuxInputInjector.terminalPaste = false;
  });

  test('Status polling never opens a permission request', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(LinuxInputInjector.channel, (
      call,
    ) async {
      calls.add(call.method);
      return status();
    });
    final controller = ControlledDeviceController();
    await controller.checkLinuxInput();
    expect(calls, ['inputStatus']);
    expect(controller.linuxInputStatus!.ready, isFalse);
    controller.dispose();
  }, skip: !Platform.isLinux);

  testWidgets(
    'Authorization is explicit and terminal paste mode reaches the native bridge',
    (tester) async {
      var response = Completer<Map<String, Object>>();
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(LinuxInputInjector.channel, (
        call,
      ) async {
        calls.add(call);
        if (call.method == 'requestAccess') return response.future;
        if (call.method == 'text') return 6;
        return status();
      });
      final controller = ControlledDeviceController();
      await controller.checkLinuxInput();
      await tester.pumpWidget(
        NetworkInputControlledApp(controller: controller),
      );
      await tester.tap(find.text('授权 / 重新检查'));
      await tester.pump();
      expect(controller.linuxAuthorizationPending, isTrue);
      final pendingButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '等待授权…'),
      );
      expect(pendingButton.onPressed, isNull);
      response.complete(status()); // Cancelled grants must remain retryable.
      await tester.pumpAndSettle();
      expect(controller.linuxAuthorizationPending, isFalse);
      expect(controller.linuxInputStatus!.ready, isFalse);

      response = Completer<Map<String, Object>>();
      await tester.tap(find.text('授权 / 重新检查'));
      await tester.pump();
      response.complete(status(ready: true));
      await tester.pumpAndSettle();
      expect(find.text('输入已授权'), findsOneWidget);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(controller.terminalPaste, isTrue);
      await LinuxInputInjector().injectText('中文😀');
      expect(calls.last.arguments, {'text': '中文😀', 'terminalPaste': 1});
      expect(calls.where((c) => c.method == 'requestAccess').length, 2);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
    skip: !Platform.isLinux,
  );

  test(
    'Late status responses after disposal do not notify listeners',
    () async {
      final response = Completer<Map<String, Object>>();
      messenger.setMockMethodCallHandler(
        LinuxInputInjector.channel,
        (_) => response.future,
      );
      final controller = ControlledDeviceController();
      final checking = controller.checkLinuxInput();
      controller.dispose();
      response.complete(status());
      await checking;
    },
    skip: !Platform.isLinux,
  );
}
