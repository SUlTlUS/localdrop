import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../models/transfer.dart';
import '../models/transfer_status.dart';
import '../services/discovery_service.dart';
import '../services/transfer_service.dart';
import '../widgets/app_background.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discoveryService = context.read<DiscoveryService>();
    final transferService = context.read<TransferService>();

    return StreamBuilder<List<Device>>(
      stream: discoveryService.devices,
      initialData: discoveryService.currentDevices,
      builder: (context, deviceSnapshot) {
        return StreamBuilder<List<Transfer>>(
          stream: transferService.transfers,
          initialData: transferService.currentTransfers,
          builder: (context, transferSnapshot) {
            final devices = deviceSnapshot.data ?? [];
            final transfers = transferSnapshot.data ?? [];

            if (devices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forum_rounded,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无可传输设备',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击底栏右侧刷新按钮重新搜索',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                final related = _transfersForDevice(transfers, device);
                final latest = related.isEmpty ? null : related.last;
                final pendingCount = related
                    .where((t) => t.isIncoming && t.status == TransferStatus.pending)
                    .length;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: GlassListTile(
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          child: Text(_avatarText(device.name)),
                        ),
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: device.isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      latest == null
                          ? '${device.ip}:${device.port}'
                          : '${latest.isIncoming ? "收到" : "发送"} ${latest.fileName} · ${_statusText(latest.status)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (pendingCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '$pendingCount',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TransferChatScreen(device: device),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class TransferChatScreen extends StatelessWidget {
  final Device device;

  const TransferChatScreen({super.key, required this.device});

  Future<void> _pickAndSend(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    if (!context.mounted) return;
    final transferService = context.read<TransferService>();
    await transferService.sendFile(
      file.path!,
      device.ip,
      device.port,
      remoteDeviceId: device.id,
      remoteDeviceName: device.name,
      senderName: transferService.deviceId,
    );

    if (!context.mounted) return;
    GlassToast.show(context, message: '已发送: ${file.name}');
  }

  @override
  Widget build(BuildContext context) {
    final transferService = context.read<TransferService>();

    return GlassPage(
      background: const AppBackground(child: SizedBox.expand()),
      statusBarStyle: GlassStatusBarStyle.auto,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: 0,
          leading: GlassIconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 17,
                child: Text(
                  _avatarText(device.name),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      device.isOnline ? '在线 · ${device.ip}' : '离线 · ${device.ip}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: StreamBuilder<List<Transfer>>(
          stream: transferService.transfers,
          initialData: transferService.currentTransfers,
          builder: (context, snapshot) {
            final transfers = _transfersForDevice(snapshot.data ?? [], device);

            if (transfers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '还没有传输记录',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '点击下方导入文件，像聊天一样发送给 ${device.name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.58),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 92),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[transfers.length - 1 - index];
                return _TransferBubble(transfer: transfer);
              },
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                GlassIconButton(
                  icon: const Icon(Icons.add_rounded, size: 22),
                  onPressed: () => _pickAndSend(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 42,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      '导入文件或拖入文件发送...',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GlassIconButton(
                  icon: const Icon(Icons.upload_file_rounded, size: 20),
                  onPressed: () => _pickAndSend(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransferBubble extends StatelessWidget {
  final Transfer transfer;

  const _TransferBubble({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final isMe = !transfer.isIncoming;
    final statusColor = switch (transfer.status) {
      TransferStatus.completed => Colors.green,
      TransferStatus.failed => Colors.red,
      TransferStatus.pending => Colors.orange,
      TransferStatus.transferring => Theme.of(context).colorScheme.primary,
    };

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insert_drive_file_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        transfer.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  transfer.fileSizeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      _statusText(transfer.status),
                      style: TextStyle(fontSize: 12, color: statusColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeText(transfer.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.42),
                      ),
                    ),
                  ],
                ),
                if (transfer.isIncoming && transfer.status == TransferStatus.pending) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GlassButton.custom(
                        onTap: () => context.read<TransferService>().acceptTransfer(transfer.id),
                        width: 72,
                        height: 34,
                        child: const Text('接收'),
                      ),
                      const SizedBox(width: 8),
                      GlassIconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => context.read<TransferService>().declineTransfer(transfer.id),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Transfer> _transfersForDevice(List<Transfer> transfers, Device device) {
  final list = transfers
      .where((t) =>
          t.remoteDeviceId == device.id ||
          t.remoteDeviceName == device.name ||
          (t.remoteDeviceId == null && t.remoteDeviceName == null))
      .toList();
  list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return list;
}

String _avatarText(String name) {
  if (name.trim().isEmpty) return '?';
  return name.trim().characters.first.toUpperCase();
}

String _statusText(TransferStatus status) => switch (status) {
      TransferStatus.pending => '等待接收',
      TransferStatus.transferring => '传输中',
      TransferStatus.completed => '已完成',
      TransferStatus.failed => '失败',
    };

String _timeText(DateTime dateTime) {
  final h = dateTime.hour.toString().padLeft(2, '0');
  final m = dateTime.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
