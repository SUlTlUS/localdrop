import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/device.dart';
import '../services/transfer_service.dart';
import '../widgets/app_background.dart';

class SendScreen extends StatelessWidget {
  final Device targetDevice;

  const SendScreen({super.key, required this.targetDevice});

  Future<void> _pickAndSend(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    if (!context.mounted) return;
    final transferService = context.read<TransferService>();
    await transferService.sendFile(file.path!, targetDevice.ip, targetDevice.port);

    if (!context.mounted) return;
    GlassToast.show(context, message: '文件已发送: ${file.name}');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: const AppBackground(child: SizedBox.expand()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('发送至 ${targetDevice.name}'),
          leading: GlassIconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassCard(
                  useOwnLayer: true,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file_rounded, size: 64,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('发送文件到', style: TextStyle(fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                      const SizedBox(height: 4),
                      Text(targetDevice.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(targetDevice.ip, style: TextStyle(fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                      const SizedBox(height: 32),
                      GlassButton.custom(
                        onTap: () => _pickAndSend(context),
                        width: 160, height: 48,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('选择文件'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
