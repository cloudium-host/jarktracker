/// Time formatting helpers.
///
/// We display timestamps raw (as UTC wall-clock values) to match what the
/// GPS-Wox admin web shows — the PHP backend runs in UTC, so the stored
/// datetimes use UTC as their source of truth. We intentionally ignore the
/// phone's timezone so values never drift between devices.
String _two(int n) => n.toString().padLeft(2, '0');

String formatTimestampRaw(int? unixSeconds) {
  if (unixSeconds == null || unixSeconds == 0) return 'Sin datos';
  final utc = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000, isUtc: true);
  return '${utc.year}-${_two(utc.month)}-${_two(utc.day)} '
      '${_two(utc.hour)}:${_two(utc.minute)}:${_two(utc.second)}';
}

String formatRelativeFromTimestamp(int? unixSeconds) {
  if (unixSeconds == null || unixSeconds == 0) return 'Sin datos';
  final eventUtc = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000, isUtc: true);
  final diff = DateTime.now().toUtc().difference(eventUtc);
  if (diff.isNegative) return formatTimestampRaw(unixSeconds);
  if (diff.inSeconds < 60) return 'hace ${diff.inSeconds}s';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'hace ${diff.inDays} d';
  return formatTimestampRaw(unixSeconds);
}
