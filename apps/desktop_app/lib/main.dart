import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter/services.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'src/application/desktop_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.addListener(_CloseToTray());
  final controller = DesktopController();
  await controller.initialize();
  await _Tray(controller).initialize();
  const options = WindowOptions(
    size: Size(640, 620),
    center: true,
    title: '网络键盘接收端',
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setPreventClose(true);
    await windowManager.hide();
  });
  runApp(DesktopReceiverApp(controller: controller));
}

class _Tray {
  _Tray(this.controller);
  final DesktopController controller;
  final SystemTray tray = SystemTray();

  Future<void> initialize() async {
    await tray.initSystemTray(
      title: '网络键盘',
      iconPath: 'windows/runner/resources/app_icon.ico',
      toolTip: '网络键盘：${controller.status}，端口 ${controller.port}',
    );
    final menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: '打开状态窗口', onClicked: (_) => _show()),
      MenuItemLabel(label: '监听端口：${controller.port}', enabled: false),
      MenuSeparator(),
      MenuItemLabel(
        label: '退出',
        onClicked: (_) async {
          await controller.shutdown();
          await tray.destroy();
          await windowManager.destroy();
          exit(0);
        },
      ),
    ]);
    await tray.setContextMenu(menu);
    tray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick ||
          eventName == kSystemTrayEventDoubleClick)
        _show();
      if (eventName == kSystemTrayEventRightClick) tray.popUpContextMenu();
    });
  }

  Future<void> _show() async {
    await windowManager.show();
    await windowManager.focus();
  }
}

class _CloseToTray with WindowListener {
  @override
  void onWindowClose() {
    windowManager.hide();
  }
}

class DesktopReceiverApp extends StatelessWidget {
  const DesktopReceiverApp({required this.controller, super.key});
  final DesktopController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '网络键盘接收端',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4f46e5)),
      useMaterial3: true,
    ),
    home: _StatusPage(controller: controller),
  );
}

class _StatusPage extends StatelessWidget {
  const _StatusPage({required this.controller});
  final DesktopController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('网络键盘接收端')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: Icon(
              controller.isListening ? Icons.lan : Icons.error_outline,
            ),
            title: Text(controller.status),
          ),
          const Divider(),
          Text('连接地址', style: Theme.of(context).textTheme.titleMedium),
          for (final address in controller.addresses)
            ListTile(
              leading: const Icon(Icons.wifi),
              title: SelectableText(address),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: address)),
              ),
            ),
          const SizedBox(height: 16),
          Text('安全码', style: Theme.of(context).textTheme.titleMedium),
          Center(
            child: SelectableText(
              controller.pairingCode,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'TLS 证书 SHA-256 指纹',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SelectableText(controller.fingerprint),
          if (controller.error != null) ...[
            const SizedBox(height: 20),
            Text(
              controller.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    ),
  );
}
