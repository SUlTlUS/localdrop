import 'transfer_status.dart';

class Transfer {
  final String id;
  final String fileName;
  final int fileSize;
  final String? remoteDeviceId;
  final String? remoteDeviceName;
  final bool isIncoming;
  TransferStatus status;
  double progress;
  String? savePath;
  String? errorMessage;
  DateTime createdAt;

  Transfer({
    required this.id,
    required this.fileName,
    required this.fileSize,
    this.remoteDeviceId,
    this.remoteDeviceName,
    required this.isIncoming,
    this.status = TransferStatus.pending,
    this.progress = 0,
    this.savePath,
    this.errorMessage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fileSizeText {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'fileSize': fileSize,
    'remoteDeviceId': remoteDeviceId,
    'remoteDeviceName': remoteDeviceName,
    'isIncoming': isIncoming,
    'status': status.name,
    'progress': progress,
    'savePath': savePath,
    'errorMessage': errorMessage,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Transfer.fromJson(Map<String, dynamic> json) => Transfer(
    id: json['id'] as String,
    fileName: json['fileName'] as String,
    fileSize: json['fileSize'] as int,
    remoteDeviceId: json['remoteDeviceId'] as String?,
    remoteDeviceName: json['remoteDeviceName'] as String?,
    isIncoming: json['isIncoming'] as bool,
    status: TransferStatus.values.firstWhere((s) => s.name == json['status']),
    progress: (json['progress'] as num).toDouble(),
    savePath: json['savePath'] as String?,
    errorMessage: json['errorMessage'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
