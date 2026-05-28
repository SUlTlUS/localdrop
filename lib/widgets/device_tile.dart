import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../models/device.dart';

class DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;

  const DeviceTile({super.key, required this.device, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassListTile(
        onTap: onTap,
        leading: GlassBadge.dot(
          dotColor: device.isOnline ? Colors.green : Colors.grey,
          child: Icon(
            Icons.computer_rounded,
            size: 20,
            color: device.isOnline ? Colors.green.shade700 : Colors.grey.shade600,
          ),
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          device.ip,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: device.isOnline
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            device.isOnline ? '在线' : '离线',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: device.isOnline ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
