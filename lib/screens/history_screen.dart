import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../services/storage_service.dart';
import '../models/transfer.dart';
import '../widgets/app_background.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storageService = StorageService();
  List<Transfer> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _storageService.loadHistory();
    if (mounted) {
      setState(() {
        _history = history.reversed.toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: const AppBackground(child: SizedBox.expand()),
      child: Scaffold(
        appBar: AppBar(title: const Text('传输历史')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('暂无传输记录', style: TextStyle(fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final t = _history[index];
                      final icon = t.status.name == 'completed'
                          ? Icons.check_circle_rounded : Icons.error_rounded;
                      final color = t.status.name == 'completed' ? Colors.green : Colors.red;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: GlassListTile(
                          leading: Icon(icon, color: color, size: 22),
                          title: Text(t.fileName, style: const TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${t.isIncoming ? "接收自" : "发送至"} ${t.remoteDeviceName ?? "未知"} · ${t.fileSizeText} · ${_fmt(t.createdAt)}',
                            style: TextStyle(fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
