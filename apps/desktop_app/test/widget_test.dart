import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_keyboard_desktop/main.dart';
import 'package:net_keyboard_desktop/src/application/desktop_controller.dart';

void main() {
  testWidgets(
    'Status page displays pairing and fingerprint before initialization',
    (tester) async {
      final controller = ControlledDeviceController();
      await tester.pumpWidget(
        NetworkInputControlledApp(controller: controller),
      );
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
        '网络键鼠受控端',
      );
      expect(find.text('网络键鼠受控端'), findsOneWidget);
      expect(find.text('安全码'), findsOneWidget);
      expect(find.text('TLS 证书 SHA-256 指纹'), findsOneWidget);
      expect(find.text('------'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
}
