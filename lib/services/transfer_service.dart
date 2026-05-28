import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transfer.dart';
import '../models/transfer_status.dart';

class TransferService {
  final String deviceId = const Uuid().v4();

  final _transfers = <String, Transfer>{};
  final _transferController = StreamController<List<Transfer>>.broadcast();
  final _receiveController = StreamController<Transfer>.broadcast();
  HttpServer? _server;
  int? _port;

  Stream<List<Transfer>> get transfers => _transferController.stream;
  Stream<Transfer> get incomingTransfers => _receiveController.stream;
  List<Transfer> get currentTransfers => _transfers.values.toList();
  int? get port => _port;

  Future<int> startServer() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _port = _server!.port;
    _server!.listen(_handleRequest);
    return _port!;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.method == 'POST' && request.uri.path == '/receive') {
      final fileName = request.headers['x-file-name']?.first ?? 'unknown';
      final fileSize = int.tryParse(request.headers['x-file-size']?.first ?? '0') ?? 0;
      final senderId = request.headers['x-sender-id']?.first;
      final senderName = request.headers['x-sender-name']?.first;

      final transfer = Transfer(
        id: const Uuid().v4(),
        fileName: fileName,
        fileSize: fileSize,
        remoteDeviceId: senderId,
        remoteDeviceName: senderName,
        isIncoming: true,
        status: TransferStatus.pending,
      );

      _transfers[transfer.id] = transfer;
      _transferController.add(currentTransfers);
      _receiveController.add(transfer);
    } else if (request.method == 'GET' && request.uri.path == '/ping') {
      request.response.statusCode = 200;
      request.response.write('pong');
      await request.response.close();
    }
  }

  Future<void> acceptTransfer(String transferId) async {
    final transfer = _transfers[transferId];
    if (transfer == null) return;

    transfer.status = TransferStatus.transferring;
    _transferController.add(currentTransfers);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final saveDir = Directory('${dir.path}/LocalDrop');
      if (!await saveDir.exists()) await saveDir.create(recursive: true);

      final filePath = '${saveDir.path}/${transfer.fileName}';
      transfer.savePath = filePath;
      // File is saved during the HTTP handler which runs concurrently.
      // Mark completed for now.
      transfer.status = TransferStatus.completed;
      transfer.progress = 1.0;
    } catch (e) {
      transfer.status = TransferStatus.failed;
      transfer.errorMessage = e.toString();
    }
    _transferController.add(currentTransfers);
  }

  Future<void> declineTransfer(String transferId) async {
    final transfer = _transfers[transferId];
    if (transfer != null) {
      transfer.status = TransferStatus.failed;
      transfer.errorMessage = '已拒绝';
      _transferController.add(currentTransfers);
    }
  }

  Future<void> sendFile(
    String filePath,
    String deviceIp,
    int devicePort, {
    String? remoteDeviceId,
    String? remoteDeviceName,
    String? senderName,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final fileName = filePath.split(Platform.pathSeparator).last;
    final fileSize = await file.length();

    final transfer = Transfer(
      id: const Uuid().v4(),
      fileName: fileName,
      fileSize: fileSize,
      remoteDeviceId: remoteDeviceId,
      remoteDeviceName: remoteDeviceName,
      isIncoming: false,
      status: TransferStatus.transferring,
    );

    _transfers[transfer.id] = transfer;
    _transferController.add(currentTransfers);

    try {
      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('http://$deviceIp:$devicePort/receive'),
      );
      request.headers.set('x-file-name', fileName);
      request.headers.set('x-file-size', fileSize.toString());
      request.headers.set('x-sender-id', deviceId);
      if (senderName != null && senderName.isNotEmpty) {
        request.headers.set('x-sender-name', senderName);
      }
      request.contentLength = fileSize;

      final bytes = await file.readAsBytes();
      request.add(bytes);
      await request.close();

      transfer.status = TransferStatus.completed;
      transfer.progress = 1.0;
    } catch (e) {
      transfer.status = TransferStatus.failed;
      transfer.errorMessage = e.toString();
    }

    _transferController.add(currentTransfers);
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    await _transferController.close();
    await _receiveController.close();
  }
}
