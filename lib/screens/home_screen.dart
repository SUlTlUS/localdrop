import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../services/discovery_service.dart';
import '../widgets/device_tile.dart';
import 'send_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discoveryService = context.read<DiscoveryService>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('LocalDrop'),
        actions: [
          GlassIconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Device>>(
        stream: discoveryService.devices,
        initialData: discoveryService.currentDevices,
        builder: (context, snapshot) {
          final devices = snapshot.data ?? [];

          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.devices_other_rounded,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正在搜索局域网设备...',
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
                    '确保其他设备也在运行 LocalDrop',
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
              return DeviceTile(
                device: device,
                onTap: device.isOnline
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SendScreen(targetDevice: device),
                          ),
                        )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
