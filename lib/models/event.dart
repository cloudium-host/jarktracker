import 'device.dart';

class AppEvent {
  AppEvent({
    required this.id,
    required this.name,
    required this.detail,
    required this.deviceName,
    required this.alertName,
    this.time,
    this.icon,
    this.lat,
    this.lng,
    this.speed,
  });

  final int id;
  final String name;
  final String detail;
  final String deviceName;
  final String alertName;
  final DeviceTime? time;
  final String? icon;
  final double? lat;
  final double? lng;
  final DeviceSpeed? speed;

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>? ?? {};
    return AppEvent(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      deviceName: (json['device']?['name'] as String?) ?? '',
      alertName: (json['alert']?['name'] as String?) ?? '',
      time: json['time'] is Map<String, dynamic>
          ? DeviceTime.fromJson(json['time'] as Map<String, dynamic>)
          : null,
      icon: json['icon'] as String?,
      lat: (coords['lat'] as num?)?.toDouble(),
      lng: (coords['lng'] as num?)?.toDouble(),
      speed: json['speed'] is Map<String, dynamic>
          ? DeviceSpeed.fromJson(json['speed'] as Map<String, dynamic>)
          : null,
    );
  }
}
