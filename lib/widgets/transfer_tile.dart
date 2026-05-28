import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../models/transfer.dart';
import '../models/transfer_status.dart';

class TransferTile extends StatelessWidget {
  final Transfer transfer;

  const TransferTile({super.key, required this.transfer});

  IconData get _statusIcon {
    switch (transfer.status) {
      case TransferStatus.completed:
        return Icons.check_circle_rounded;
      case TransferStatus.failed:
        return Icons.error_rounded;
      case TransferStatus.transferring:
        return Icons.sync_rounded;
      case TransferStatus.pending:
        return Icons.hourglass_bottom_rounded;
    }
  }

  Color get _statusColor {
    switch (transfer.status) {
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
        return Colors.red;
      case TransferStatus.transferring:
        return Colors.blue;
      case TransferStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassListTile(
        leading: Icon(_statusIcon, color: _statusColor, size: 24),
        title: Text(
          transfer.fileName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${transfer.isIncoming ? "来自" : "发送至"} ${transfer.remoteDeviceName ?? "未知"} · ${transfer.fileSizeText}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (transfer.status == TransferStatus.transferring)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GlassProgressIndicator.linear(value: transfer.progress),
              ),
          ],
        ),
      ),
    );
  }
}
