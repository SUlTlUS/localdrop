class Device {
  final String id;
  final String name;
  final String ip;
  final int port;
  DateTime lastSeen;

  Device({
    required this.id,
    required this.name,
    required this.ip,
    required this.port,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  bool get isOnline => DateTime.now().difference(lastSeen).inSeconds < 15;

  @override
  bool operator ==(Object other) =>
      other is Device && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
