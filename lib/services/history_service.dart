import 'package:latlong2/latlong.dart';
import 'api_client.dart';

class HistoryPoint {
  HistoryPoint({
    required this.lat,
    required this.lng,
    required this.time,
    this.speed,
    this.color,
  });
  final double lat;
  final double lng;
  final String time;
  final double? speed;
  final String? color;
}

class HistoryStat {
  HistoryStat({required this.key, required this.title, required this.value});
  final String key;
  final String title;
  final String value;

  factory HistoryStat.fromJson(Map<String, dynamic> j) => HistoryStat(
        key: j['key'] as String? ?? '',
        title: j['title'] as String? ?? '',
        value: j['value']?.toString() ?? '',
      );
}

class HistoryResult {
  HistoryResult({required this.stats, required this.points});
  final List<HistoryStat> stats;
  final List<HistoryPoint> points;
}

class HistoryService {
  Future<HistoryResult> get({
    required int deviceId,
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await ApiClient.instance.get('/history', query: {
      'device_id': deviceId,
      'from': _fmt(from),
      'to': _fmt(to),
    });
    final raw = res.data;
    if (raw is! Map<String, dynamic>) return HistoryResult(stats: const [], points: const []);
    final data = raw['data'];
    if (data is! Map<String, dynamic>) return HistoryResult(stats: const [], points: const []);

    final stats = ((data['stats'] as List<dynamic>?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HistoryStat.fromJson)
        .toList();

    final points = <HistoryPoint>[];
    final items = (data['items'] as List<dynamic>?) ?? const [];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final positions = (item['positions'] as List<dynamic>?) ?? const [];
      for (final p in positions) {
        if (p is! Map<String, dynamic>) continue;
        final lat = p['lat'];
        final lng = p['lng'];
        double? plat, plng;
        if (lat is num) plat = lat.toDouble();
        if (lat is String) plat = double.tryParse(lat);
        if (lng is num) plng = lng.toDouble();
        if (lng is String) plng = double.tryParse(lng);
        if (plat == null || plng == null) continue;
        points.add(
          HistoryPoint(
            lat: plat,
            lng: plng,
            time: p['t']?.toString() ?? '',
            speed: double.tryParse(p['s']?.toString() ?? ''),
            color: p['c'] as String?,
          ),
        );
      }
    }
    return HistoryResult(stats: stats, points: points);
  }

  static List<LatLng> toLatLngList(List<HistoryPoint> pts) =>
      pts.map((p) => LatLng(p.lat, p.lng)).toList();

  String _fmt(DateTime d) {
    final local = d; // already UTC; backend accepts space-separated datetime
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(2, '0')}';
  }
}
