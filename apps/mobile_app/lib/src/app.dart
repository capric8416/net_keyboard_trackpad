import 'package:flutter/material.dart';

import 'application/keyboard_controller.dart';
import 'infrastructure/remote_input_gateway.dart';
import 'presentation/device_list_screen.dart';
import 'presentation/keyboard_screen.dart';

class RemoteKeyboardApp extends StatefulWidget {
  const RemoteKeyboardApp({super.key});

  @override
  State<RemoteKeyboardApp> createState() => _RemoteKeyboardAppState();
}

class _RemoteKeyboardAppState extends State<RemoteKeyboardApp> {
  late final GrpcRemoteInputGateway _gateway;
  late final KeyboardController _controller;
  bool _initializing = true;
  bool _showDevices = false;

  @override
  void initState() {
    super.initState();
    _gateway = GrpcRemoteInputGateway();
    _controller = KeyboardController(_gateway);
    _gateway.statusChanges.addListener(_refresh);
    _restore();
  }

  Future<void> _restore() async {
    final profile = await _gateway.loadProfile();
    if (profile != null && profile.isPaired) {
      try {
        await _gateway.connect(profile);
      } on Object {
        // The setup page shows the connection error and permits re-pairing.
      }
    }
    if (mounted) setState(() => _initializing = false);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _gateway.statusChanges.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '网络键盘',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff4f46e5),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    home: _initializing
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _showDevices || !_gateway.hasPairedProfile
        ? DeviceListScreen(
            gateway: _gateway,
            canReturnToKeyboard: _gateway.hasPairedProfile,
            onConnected: () => setState(() => _showDevices = false),
          )
        : KeyboardScreen(
            controller: _controller,
            onManageDevices: () => setState(() => _showDevices = true),
          ),
  );
}
