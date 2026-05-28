import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/device.dart';

class DiscoveryService {
  static const int _discoveryPort = 53321;
  static const String _discoveryMessage = 'LOCALDROP_DISCOVERY';
  static const Duration _broadcastInterval = Duration(seconds: 5);
  static const Duration _cleanupInterval = Duration(seconds: 15);

  final String deviceId;
  final String deviceName;
  final int servicePort;

  final _devices = <String, Device>{};
  final _deviceController = StreamController<List<Device>>.broadcast();
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;
  bool _running = false;

  DiscoveryService({
    required this.servicePort,
    String? deviceName,
  })  : deviceId = const Uuid().v4(),
        deviceName = deviceName ?? Platform.localHostname;

  Stream<List<Device>> get devices => _deviceController.stream;
  List<Device> get currentDevices => _devices.values.toList();

  Future<void> start() async {
    if (_running) return;
    _running = true;

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _discoveryPort);
    _socket!.broadcastEnabled = true;

    _socket!.listen((event) {
      if (event == RawSocketEvent.read) {
        _handlePacket(_socket!);
      }
    });

    _broadcastTimer = Timer.periodic(_broadcastInterval, (_) => _broadcast());
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) => _cleanupOffline());
    _broadcast();
  }

  void _broadcast() {
    if (_socket == null) return;
    final data = jsonEncode({
      'id': deviceId,
      'name': deviceName,
      'port': servicePort,
    });
    final packet = '$_discoveryMessage|$data';
    final encoded = utf8.encode(packet);
    _socket!.send(encoded, InternetAddress('255.255.255.255'), _discoveryPort);
  }

  void _handlePacket(RawDatagramSocket socket) {
    final datagram = socket.receive();
    if (datagram == null) return;
    final message = utf8.decode(datagram.data);
    if (!message.startsWith(_discoveryMessage)) return;

    final jsonStr = message.substring(_discoveryMessage.length + 1);
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final id = data['id'] as String;
      if (id == deviceId) return;

      final ip = datagram.address.address;
      _devices[id] = Device(
        id: id,
        name: data['name'] as String,
        ip: ip,
        port: data['port'] as int,
        lastSeen: DateTime.now(),
      );
      _deviceController.add(currentDevices);
    } catch (_) {}
  }

  void _cleanupOffline() {
    _devices.removeWhere((_, d) => !d.isOnline);
    _deviceController.add(currentDevices);
  }

  Future<void> stop() async {
    _running = false;
    _broadcastTimer?.cancel();
    _cleanupTimer?.cancel();
    _socket?.close();
    _socket = null;
    await _deviceController.close();
  }
}
