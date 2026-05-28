import 'dart:io';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'services/discovery_service.dart';
import 'services/transfer_service.dart';
import 'services/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LiquidGlassWidgets.initialize(
    enablePerformanceMonitor: false,
  );

  final transferService = TransferService();
  final port = await transferService.startServer();

  final discoveryService = DiscoveryService(
    deviceName: Platform.localHostname,
    servicePort: port,
  );
  await discoveryService.start();

  runApp(
    LiquidGlassWidgets.wrap(
      // Keep the premium/standard settings requested by the bottom bar instead
      // of allowing adaptive quality to downgrade them on desktop or slower GPUs.
      adaptiveQuality: false,
      child: MultiProvider(
        providers: [
          Provider<DiscoveryService>.value(value: discoveryService),
          Provider<TransferService>.value(value: transferService),
          Provider<StorageService>(create: (_) => StorageService()),
        ],
        child: const LocalDropApp(),
      ),
    ),
  );
}
