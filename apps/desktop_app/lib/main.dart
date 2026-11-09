import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'src/application/desktop_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final controller = ControlledDeviceController();
  await controller.initialize();
  bool trayReady = false;
  try {
    trayReady = await _Tray(controller).initialize();
  } on PlatformException {
    // Keep the status and error page accessible without a working tray host.
  }
  const options = WindowOptions(
    size: Size(640, 620),
    center: true,
    title: '网络键鼠受控端',
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setPreventClose(trayReady);
    if (trayReady) {
      windowManager.addListener(_CloseToTray());
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  });
  runApp(NetworkInputControlledApp(controller: controller));
}

class _Tray {
  _Tray(this.controller);
  final ControlledDeviceController controller;
  final SystemTray tray = SystemTray();

  Future<bool> initialize() async {
    final ready = await tray.initSystemTray(
      title: '网络键鼠受控端',
      iconPath: !Platform.isWindows
          ? 'assets/tray_icon.png'
          : 'windows/runner/resources/app_icon.ico',
      toolTip: '网络键鼠受控端：${controller.status}，端口 ${controller.port}',
    );
    if (!ready) return false;
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
          // GTK window destruction removes Flutter's implicit view while its
          // engine is still running. Let process exit release it on Linux.
          if (!Platform.isLinux) {
            await windowManager.destroy();
          }
          exit(0);
        },
      ),
    ]);
    await tray.setContextMenu(menu);
    tray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick ||
          eventName == kSystemTrayEventDoubleClick) {
        _show();
      }
      if (eventName == kSystemTrayEventRightClick) tray.popUpContextMenu();
    });
    return true;
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

class NetworkInputControlledApp extends StatelessWidget {
  const NetworkInputControlledApp({required this.controller, super.key});
  final ControlledDeviceController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '网络键鼠受控端',
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
  final ControlledDeviceController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('网络键鼠受控端')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: Icon(
              controller.isListening ? Icons.lan : Icons.error_outline,
            ),
            title: Text(controller.status),
          ),
          if (Platform.isMacOS)
            ListTile(
              leading: Icon(
                controller.accessibilityTrusted
                    ? Icons.check_circle
                    : Icons.accessibility_new,
              ),
              title: Text(
                controller.accessibilityTrusted
                    ? '辅助功能已授权'
                    : '需要辅助功能权限才能控制键盘和鼠标',
              ),
              subtitle: const Text('系统设置 → 隐私与安全性 → 辅助功能；授权后点击重新检查'),
              trailing: TextButton(
                onPressed: () => controller.checkAccessibility(
                  prompt: !controller.accessibilityTrusted,
                ),
                child: const Text('授权 / 重新检查'),
              ),
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
