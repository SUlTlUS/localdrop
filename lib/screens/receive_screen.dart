import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import '../models/transfer.dart';
import '../models/transfer_status.dart';
import '../services/transfer_service.dart';
import '../widgets/app_background.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transferService = context.read<TransferService>();

    return GlassPage(
      background: const AppBackground(child: SizedBox.expand()),
      child: Scaffold(
        appBar: AppBar(title: const Text('传输队列')),
        body: StreamBuilder<List<Transfer>>(
          stream: transferService.transfers,
          initialData: transferService.currentTransfers,
          builder: (context, snapshot) {
            final transfers = snapshot.data ?? [];
            final pending = transfers.where((t) => t.status == TransferStatus.pending).toList();
            final active = transfers.where((t) => t.status != TransferStatus.pending).toList();

            if (transfers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_rounded, size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text('暂无传输任务', style: TextStyle(fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (pending.isNotEmpty) ...[
                  _sectionHeader(context, '待处理'),
                  ...pending.map((t) => _PendingTransferCard(transfer: t)),
                ],
                if (active.isNotEmpty) ...[
                  _sectionHeader(context, '传输记录'),
                  ...active.map((t) {
                    final icon = t.status == TransferStatus.completed
                        ? Icons.check_circle_rounded
                        : t.status == TransferStatus.failed
                            ? Icons.error_rounded
                            : Icons.sync_rounded;
                    final color = t.status == TransferStatus.completed
                        ? Colors.green
                        : t.status == TransferStatus.failed
                            ? Colors.red
                            : Colors.blue;
                    return ListTile(
                      leading: Icon(icon, color: color),
                      title: Text(t.fileName),
                      subtitle: Text('${t.fileSizeText} · ${t.remoteDeviceName ?? ""}'),
                    );
                  }),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
    );
  }
}

class _PendingTransferCard extends StatelessWidget {
  final Transfer transfer;
  const _PendingTransferCard({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final transferService = context.read<TransferService>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transfer.fileName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('来自 ${transfer.remoteDeviceName ?? "未知"} · ${transfer.fileSizeText}',
                      style: TextStyle(fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            GlassButton.custom(
              onTap: () => transferService.acceptTransfer(transfer.id),
              width: 44, height: 44,
              child: const Icon(Icons.check, size: 18),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => transferService.declineTransfer(transfer.id),
            ),
          ],
        ),
      ),
    );
  }
}
