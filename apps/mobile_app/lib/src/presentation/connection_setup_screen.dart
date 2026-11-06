import 'package:flutter/material.dart';

import '../infrastructure/remote_input_gateway.dart';

class ConnectionSetupScreen extends StatefulWidget {
  const ConnectionSetupScreen({required this.gateway, super.key});
  final GrpcRemoteInputGateway gateway;

  @override
  State<ConnectionSetupScreen> createState() => _ConnectionSetupScreenState();
}

class _ConnectionSetupScreenState extends State<ConnectionSetupScreen> {
  final _host = TextEditingController();
  final _port = TextEditingController(text: '39091');
  final _fingerprint = TextEditingController();
  final _totp = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await widget.gateway.loadProfile();
    if (profile == null || !mounted) return;
    _host.text = profile.host;
    _port.text = profile.port.toString();
    _fingerprint.text = profile.fingerprint;
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    _fingerprint.dispose();
    _totp.dispose();
    super.dispose();
  }

  Future<void> _pair() async {
    final port = int.tryParse(_port.text);
    if (_host.text.trim().isEmpty ||
        port == null ||
        _fingerprint.text.trim().isEmpty ||
        _totp.text.trim().length != 6) {
      setState(() => _error = '请填写地址、端口、证书指纹和 6 位验证码');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.gateway.configureAndPair(
        host: _host.text.trim(),
        port: port,
        fingerprint: _fingerprint.text,
        totp: _totp.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('连接被控端')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(widget.gateway.status.message ?? '配置接收端'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _host,
                    decoration: const InputDecoration(labelText: 'IP 或主机名'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: _port,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '端口'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fingerprint,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'TLS SHA-256 指纹',
                helperText: '逐字核对被控端状态窗口中的指纹。',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(labelText: '验证码'),
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            FilledButton.icon(
              onPressed: _busy ? null : _pair,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link),
              label: const Text('配对并连接'),
            ),
          ],
        ),
      ),
    ),
  );
}
