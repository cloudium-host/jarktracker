class DeviceStatus {
  DeviceStatus({required this.type, required this.title, required this.color});
  final String type;
  final String title;
  final String color;

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => DeviceStatus(
        type: json['type'] as String? ?? 'unknown',
        title: json['title'] as String? ?? '',
        color: json['color'] as String? ?? '#808080',
      );
}

class DeviceSpeed {
  DeviceSpeed({required this.value, required this.unit, required this.human});
  final double value;
  final String unit;
  final String human;

  factory DeviceSpeed.fromJson(Map<String, dynamic> json) => DeviceSpeed(
        value: (json['value'] as num?)?.toDouble() ?? 0,
        unit: json['unit'] as String? ?? 'kph',
        human: json['human'] as String? ?? '0 kph',
      );
}

class DeviceIcon {
  DeviceIcon({this.width, this.height, this.url, this.color, this.course});
  final int? width;
  final int? height;
  final String? url;
  final String? color;
  final double? course;

  factory DeviceIcon.fromJson(Map<String, dynamic> json) => DeviceIcon(
        width: (json['width'] as num?)?.toInt(),
        height: (json['height'] as num?)?.toInt(),
        url: json['url'] as String?,
        color: json['color'] as String?,
        course: (json['course'] as num?)?.toDouble(),
      );
}

class DeviceTime {
  DeviceTime({required this.timestamp, required this.formatted});
  final int timestamp;
  final String formatted;

  factory DeviceTime.fromJson(Map<String, dynamic> json) => DeviceTime(
        timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
        formatted: json['formatted'] as String? ?? '',
      );
}

class Device {
  Device({
    required this.id,
    required this.imei,
    required this.name,
    required this.active,
    required this.status,
    required this.speed,
    required this.icon,
    this.time,
    this.engineStatus,
  });

  final int id;
  final String imei;
  final String name;
  final bool active;
  final DeviceStatus status;
  final DeviceSpeed speed;
  final DeviceIcon icon;
  final DeviceTime? time;
  final String? engineStatus;

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: (json['id'] as num).toInt(),
      imei: json['imei'] as String? ?? '',
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      status: DeviceStatus.fromJson(json['status'] as Map<String, dynamic>? ?? {}),
      speed: DeviceSpeed.fromJson(json['speed'] as Map<String, dynamic>? ?? {}),
      icon: DeviceIcon.fromJson(json['icon'] as Map<String, dynamic>? ?? {}),
      time: json['time'] is Map<String, dynamic>
          ? DeviceTime.fromJson(json['time'] as Map<String, dynamic>)
          : null,
      engineStatus: json['engine_status'] as String?,
    );
  }
}
