import 'package:flutter/material.dart';

import 'application/keyboard_controller.dart';
import 'infrastructure/remote_input_gateway.dart';
import 'presentation/device_list_screen.dart';
import 'presentation/keyboard_screen.dart';

class NetworkInputControllerApp extends StatefulWidget {
  const NetworkInputControllerApp({super.key});

  @override
  State<NetworkInputControllerApp> createState() =>
      _NetworkInputControllerAppState();
}

class _NetworkInputControllerAppState extends State<NetworkInputControllerApp> {
  late final GrpcRemoteInputGateway _gateway;
  late final KeyboardController _controller;
  bool _initializing = true;
  bool _showDevices = true;

  @override
  void initState() {
    super.initState();
    _gateway = GrpcRemoteInputGateway();
    _controller = KeyboardController(_gateway);
    _gateway.statusChanges.addListener(_refresh);
    _restore();
  }

  Future<void> _restore() async {
    await _gateway.loadProfile();
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
    title: '网络键鼠控制端',
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
