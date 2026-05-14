import 'device.dart';

class LatLngPair {
  LatLngPair(this.lat, this.lng);
  final double lat;
  final double lng;

  static LatLngPair? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final lat = raw['lat'];
    final lng = raw['lng'];
    double? l1, l2;
    if (lat is num) l1 = lat.toDouble();
    if (lat is String) l1 = double.tryParse(lat);
    if (lng is num) l2 = lng.toDouble();
    if (lng is String) l2 = double.tryParse(lng);
    if (l1 == null || l2 == null) return null;
    return LatLngPair(l1, l2);
  }
}

class DeviceMapItem {
  DeviceMapItem({
    required this.id,
    required this.imei,
    required this.name,
    required this.status,
    required this.speed,
    required this.icon,
    this.lat,
    this.lng,
    this.time,
    this.tail = const [],
  });

  final int id;
  final String imei;
  final String name;
  final DeviceStatus status;
  final DeviceSpeed speed;
  final DeviceIcon icon;
  final double? lat;
  final double? lng;
  final DeviceTime? time;
  final List<LatLngPair> tail;

  factory DeviceMapItem.fromJson(Map<String, dynamic> json) {
    final coords = LatLngPair.tryParse(json['coordinates']);
    final tailRaw = json['tail'];
    final tailCoords = <LatLngPair>[];
    if (tailRaw is Map && tailRaw['coordinates'] is List) {
      for (final c in tailRaw['coordinates'] as List) {
        final p = LatLngPair.tryParse(c);
        if (p != null) tailCoords.add(p);
      }
    }
    return DeviceMapItem(
      id: (json['id'] as num).toInt(),
      imei: json['imei'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: DeviceStatus.fromJson(json['status'] as Map<String, dynamic>? ?? {}),
      speed: DeviceSpeed.fromJson(json['speed'] as Map<String, dynamic>? ?? {}),
      icon: DeviceIcon.fromJson(json['icon'] as Map<String, dynamic>? ?? {}),
      lat: coords?.lat,
      lng: coords?.lng,
      time: json['time'] is Map<String, dynamic>
          ? DeviceTime.fromJson(json['time'] as Map<String, dynamic>)
          : null,
      tail: tailCoords,
    );
  }
}
