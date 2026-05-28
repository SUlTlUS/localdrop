import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/device.dart';

class DiscoveryService {
  static const int _discoveryPort = 53321;
  static const String _discoveryMessage = 'LOCALDROP_DISCOVERY';
  static const Duration _broadcastInterval = Duration(seconds: 3);
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

    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      _discoveryPort,
      reuseAddress: true,
      reusePort: Platform.isAndroid || Platform.isIOS || Platform.isMacOS,
    );
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

  void refresh() {
    _broadcast();
    _cleanupOffline();
  }

  Future<void> _broadcast() async {
    final socket = _socket;
    if (socket == null) return;

    final data = jsonEncode({
      'id': deviceId,
      'name': deviceName,
      'port': servicePort,
    });
    final encoded = utf8.encode('$_discoveryMessage|$data');

    final targets = await _broadcastTargets();
    for (final target in targets) {
      try {
        socket.send(encoded, target, _discoveryPort);
      } catch (_) {
        // Some platforms reject a specific broadcast address. Keep trying the
        // rest of the targets instead of failing the whole discovery pass.
      }
    }
  }

  Future<Set<InternetAddress>> _broadcastTargets() async {
    final targets = <InternetAddress>{
      InternetAddress('255.255.255.255'),
    };

    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          final broadcast = _ipv4BroadcastAddress(address.address);
          if (broadcast != null) {
            targets.add(InternetAddress(broadcast));
          }
        }
      }
    } catch (_) {}

    return targets;
  }

  String? _ipv4BroadcastAddress(String address) {
    final parts = address.split('.');
    if (parts.length != 4) return null;
    final octets = parts.map(int.tryParse).toList();
    if (octets.any((part) => part == null || part < 0 || part > 255)) {
      return null;
    }

    // Most home and campus Wi-Fi LANs use /24. Sending to both the limited
    // broadcast address and this subnet broadcast covers routers that drop
    // 255.255.255.255 but allow e.g. 192.168.1.255.
    return '${octets[0]}.${octets[1]}.${octets[2]}.255';
  }

  void _handlePacket(RawDatagramSocket socket) {
    final datagram = socket.receive();
    if (datagram == null) return;
    final message = utf8.decode(datagram.data, allowMalformed: true);
    if (!message.startsWith(_discoveryMessage)) return;

    final jsonStr = message.substring(_discoveryMessage.length + 1);
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final id = data['id'] as String;
      if (id == deviceId) return;

      final port = data['port'];
      if (port is! int) return;

      final ip = datagram.address.address;
      _devices[id] = Device(
        id: id,
        name: data['name'] as String? ?? ip,
        ip: ip,
        port: port,
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
