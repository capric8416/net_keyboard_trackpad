import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_keyboard_mobile/src/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('First launch shows saved devices before connecting', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const NetworkInputControllerApp());
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
      '网络键鼠控制端',
    );
    expect(find.text('已保存的受控端'), findsOneWidget);
    expect(find.text('尚未保存受控端'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
