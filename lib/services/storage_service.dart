import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/transfer.dart';

class StorageService {
  Future<String> get _historyPath async {
    final dir = await getApplicationDocumentsDirectory();
    final saveDir = Directory('${dir.path}/LocalDrop');
    if (!await saveDir.exists()) await saveDir.create(recursive: true);
    return '${saveDir.path}/transfer_history.json';
  }

  Future<List<Transfer>> loadHistory() async {
    try {
      final path = await _historyPath;
      final file = File(path);
      if (!await file.exists()) return [];
      final data = jsonDecode(await file.readAsString()) as List<dynamic>;
      return data.map((j) => Transfer.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<Transfer> transfers) async {
    try {
      final path = await _historyPath;
      final file = File(path);
      final data = transfers.map((t) => t.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}
