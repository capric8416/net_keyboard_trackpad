import 'package:flutter/material.dart';

import '../infrastructure/remote_input_gateway.dart';
import 'connection_setup_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({
    required this.gateway,
    required this.onConnected,
    this.canReturnToKeyboard = false,
    super.key,
  });

  final GrpcRemoteInputGateway gateway;
  final VoidCallback onConnected;
  final bool canReturnToKeyboard;

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<ServerProfile> _profiles = const [];
  String? _busyProfileId;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.gateway.statusChanges.addListener(_refreshStatus);
    _reload();
  }

  @override
  void dispose() {
    widget.gateway.statusChanges.removeListener(_refreshStatus);
    super.dispose();
  }

  void _refreshStatus() {
    if (mounted) setState(() {});
  }

  Future<void> _reload() async {
    final profiles = await widget.gateway.loadProfiles();
    if (mounted) setState(() => _profiles = profiles);
  }

  Future<void> _connect(ServerProfile profile) async {
    setState(() {
      _busyProfileId = profile.id;
      _error = null;
    });
    try {
      await widget.gateway.connect(profile);
      if (mounted) widget.onConnected();
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busyProfileId = null);
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _busyProfileId = widget.gateway.activeProfile?.id;
      _error = null;
    });
    await widget.gateway.disconnect();
    if (mounted) setState(() => _busyProfileId = null);
  }

  Future<void> _delete(ServerProfile profile) async {
    setState(() {
      _busyProfileId = profile.id;
      _error = null;
    });
    await widget.gateway.deleteProfile(profile);
    await _reload();
    if (mounted) setState(() => _busyProfileId = null);
  }

  Future<void> _addDevice() async {
    final paired = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ConnectionSetupScreen(gateway: widget.gateway),
      ),
    );
    await _reload();
    if (paired == true && mounted) widget.onConnected();
  }

  @override
  Widget build(BuildContext context) {
    final activeId = widget.gateway.activeProfile?.id;
    final connected = widget.gateway.status.canSend;
    return Scaffold(
      appBar: AppBar(
        leading: widget.canReturnToKeyboard
            ? IconButton(
                onPressed: widget.onConnected,
                icon: const Icon(Icons.arrow_back),
                tooltip: '返回键盘',
              )
            : null,
        title: const Text('已保存的设备'),
        actions: [
          IconButton(
            onPressed: _addDevice,
            icon: const Icon(Icons.add),
            tooltip: '添加设备',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              MaterialBanner(
                content: Text(_error!),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _error = null),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            if (_profiles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 72),
                child: Column(
                  children: [
                    Icon(Icons.devices_other, size: 64),
                    SizedBox(height: 16),
                    Text('尚未保存设备'),
                    SizedBox(height: 8),
                    Text('点击右上角添加设备并完成首次配对。'),
                  ],
                ),
              ),
            for (final profile in _profiles)
              _DeviceCard(
                profile: profile,
                isActive: activeId == profile.id,
                isConnected: activeId == profile.id && connected,
                canDisconnect:
                    activeId == profile.id && widget.gateway.connectionEnabled,
                busy: _busyProfileId == profile.id,
                statusMessage: activeId == profile.id
                    ? widget.gateway.status.message
                    : null,
                onConnect: () => _connect(profile),
                onDisconnect: _disconnect,
                onDelete: () => _delete(profile),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDevice,
        icon: const Icon(Icons.add),
        label: const Text('添加设备'),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.profile,
    required this.isActive,
    required this.isConnected,
    required this.canDisconnect,
    required this.busy,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
    this.statusMessage,
  });

  final ServerProfile profile;
  final bool isActive;
  final bool isConnected;
  final bool canDisconnect;
  final bool busy;
  final String? statusMessage;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(
        isConnected ? Icons.desktop_windows : Icons.computer,
        color: isConnected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text('${profile.host}:${profile.port}'),
      subtitle: Text(
        [
          if (isConnected) '已连接' else if (isActive) statusMessage ?? '当前设备',
          '指纹 ${_shortFingerprint(profile.fingerprint)}',
        ].join('\n'),
      ),
      isThreeLine: isActive,
      trailing: busy
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canDisconnect)
                  TextButton(onPressed: onDisconnect, child: const Text('断开'))
                else
                  FilledButton.tonal(
                    onPressed: onConnect,
                    child: const Text('连接'),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'delete', child: Text('删除设备')),
                  ],
                ),
              ],
            ),
    ),
  );
}

String _shortFingerprint(String fingerprint) {
  final parts = fingerprint.split(':');
  if (parts.length <= 6) return fingerprint;
  return '…${parts.sublist(parts.length - 6).join(':')}';
}
