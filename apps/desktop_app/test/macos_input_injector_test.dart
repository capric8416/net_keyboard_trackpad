import 'package:flutter/services.dart' show MethodCall, PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:net_keyboard_desktop/src/application/macos_input_injector.dart';
import 'package:remote_input_core/remote_input_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  final input = MacOSInputInjector();
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MacOSInputInjector.channel, (call) async {
          calls.add(call);
          if (call.method == 'isTrusted') return false;
          if (call.method == 'text') {
            throw PlatformException(
              code: 'INPUT_BLOCKED',
              message: 'permission denied',
            );
          }
          return 4;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MacOSInputInjector.channel, null),
  );

  test('Permission checks do not prompt unless explicitly requested', () async {
    expect(await input.isTrusted(), isFalse);
    expect(calls.single.arguments, {'prompt': false});
    await input.isTrusted(prompt: true);
    expect(calls.last.arguments, {'prompt': true});
  });
  test('Command and right Option preserve wire modifier bits', () async {
    final bits = ModifierKey.leftMeta.bit | ModifierKey.rightAlt.bit;
    expect(
      await input.injectKeyStroke(
        KeyStroke(key: SemanticKey.keyC, modifierBits: bits),
      ),
      4,
    );
    expect(calls.single.method, 'keyStroke');
    expect(calls.single.arguments, {'key': 'keyC', 'modifiers': bits});
  });
  test('Native denial propagates and Unicode text remains intact', () async {
    await expectLater(
      input.injectText('中文😀'),
      throwsA(isA<PlatformException>()),
    );
    expect(calls.single.arguments, {'text': '中文😀'});
  });
  test('Pointer sends both wheel axes and button state together', () async {
    await input.injectPointer(
      deltaX: -2,
      deltaY: 3,
      wheelDelta: 120,
      horizontalWheelDelta: -120,
      button: PointerButton.right,
      buttonDown: true,
    );
    expect(calls.single.arguments, {
      'deltaX': -2,
      'deltaY': 3,
      'wheelDelta': 120,
      'horizontalWheelDelta': -120,
      'button': 'right',
      'buttonDown': true,
    });
  });
}
