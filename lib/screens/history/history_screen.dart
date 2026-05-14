import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/time_format.dart';
import '../../models/device.dart';
import '../../widgets/device_thumb.dart';
import '../../services/devices_service.dart';
import '../../services/history_service.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Device> _devices = [];
  Device? _selected;
  bool _loadingDevices = true;
  bool _loadingHistory = false;
  HistoryResult _result = HistoryResult(stats: const [], points: const []);
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final list = await DevicesService().list();
      if (!mounted) return;
      setState(() {
        _devices = list;
        _loadingDevices = false;
      });
    } catch (e) {
      setState(() {
        _loadingDevices = false;
        _error = e;
      });
    }
  }

  Future<void> _loadHistory(Device d) async {
    setState(() {
      _selected = d;
      _loadingHistory = true;
      _error = null;
      _result = HistoryResult(stats: const [], points: const []);
    });
    try {
      // Ecuador wall-clock "now" and 24h back (server expects Ecuador time).
      final nowEcuador = DateTime.now().toUtc().subtract(const Duration(hours: 5));
      final fromEcuador = nowEcuador.subtract(const Duration(hours: 24));
      final result = await HistoryService().get(
        deviceId: d.id,
        from: fromEcuador,
        to: nowEcuador,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _loadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _DeviceSelector(
                devices: _devices,
                selected: _selected,
                loading: _loadingDevices,
                onPick: _loadHistory,
              ),
            ),
            if (_selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: _DeviceInfoCard(
                  device: _selected!,
                  pointCount: _result.points.length,
                  stats: _result.stats,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _MapBody(
                    points: _result.points,
                    loading: _loadingHistory,
                    error: _error,
                    hasSelection: _selected != null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceSelector extends StatelessWidget {
  const _DeviceSelector({
    required this.devices,
    required this.selected,
    required this.loading,
    required this.onPick,
  });
  final List<Device> devices;
  final Device? selected;
  final bool loading;
  final ValueChanged<Device> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Device>(
          isExpanded: true,
          value: selected,
          hint: Text(
            loading ? 'Cargando...' : 'Seleccionar dispositivo',
            style: const TextStyle(color: Colors.white70),
          ),
          dropdownColor: AppColors.navyLight,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: devices
              .map(
                (d) => DropdownMenuItem(
                  value: d,
                  child: Text(d.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (d) {
            if (d != null) onPick(d);
          },
        ),
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({
    required this.device,
    required this.pointCount,
    required this.stats,
  });
  final Device device;
  final int pointCount;
  final List<HistoryStat> stats;

  String? _statValue(String key) {
    for (final s in stats) {
      if (s.key == key) return s.value;
    }
    return null;
  }

  Color get _statusColor {
    switch (device.status.type) {
      case 'online':
        return AppColors.online;
      case 'offline':
        return AppColors.offline;
      default:
        return AppColors.idle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final distance = _statValue('distance');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              DeviceThumb(
                iconUrl: device.icon.url,
                size: 44,
                borderColor: _statusColor,
                background: palette.background,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _HistoryInfoLine(
            icon: Icons.qr_code_2,
            label: 'IMEI',
            value: device.imei,
            palette: palette,
          ),
          _HistoryInfoLine(
            icon: Icons.circle,
            iconColor: _statusColor,
            label: 'Estado',
            value: device.status.title,
            valueColor: _statusColor,
            palette: palette,
          ),
          _HistoryInfoLine(
            icon: Icons.speed,
            label: 'Velocidad',
            value: device.speed.human,
            palette: palette,
          ),
          _HistoryInfoLine(
            icon: Icons.access_time,
            label: 'Sincronización',
            value: formatTimestampRaw(device.time?.timestamp),
            palette: palette,
          ),
          if (distance != null || pointCount > 0)
            _HistoryInfoLine(
              icon: Icons.route,
              label: 'Recorrido 24h',
              value:
                  '${pointCount > 0 ? "$pointCount pts" : ""}${distance != null ? (pointCount > 0 ? "  •  " : "") + distance : ""}',
              palette: palette,
            ),
        ],
      ),
    );
  }
}

class _HistoryInfoLine extends StatelessWidget {
  const _HistoryInfoLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.palette,
    this.iconColor,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final AppPalette palette;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: iconColor ?? palette.textSecondary),
          const SizedBox(width: 6),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: palette.textSecondary, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _MapBody extends StatelessWidget {
  const _MapBody({
    required this.points,
    required this.loading,
    required this.error,
    required this.hasSelection,
  });
  final List<HistoryPoint> points;
  final bool loading;
  final Object? error;
  final bool hasSelection;

  @override
  Widget build(BuildContext context) {
    if (!hasSelection) {
      return Container(
        color: AppColors.navyLight,
        alignment: Alignment.center,
        child: const Text(
          'Elige un dispositivo\npara ver el recorrido',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    if (loading) {
      return Container(
        color: AppColors.navyLight,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }
    if (error != null) {
      return Container(
        color: AppColors.navyLight,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }
    if (points.isEmpty) {
      return Container(
        color: AppColors.navyLight,
        alignment: Alignment.center,
        child: const Text(
          'Sin recorrido en las últimas 24 h',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    final latLngs = HistoryService.toLatLngList(points);
    final center = latLngs.first;
    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jarkenterprises.jarktracker',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: latLngs, strokeWidth: 4, color: AppColors.red),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: latLngs.first,
              width: 30,
              height: 30,
              child: const Icon(Icons.play_circle_fill, color: AppColors.online, size: 30),
            ),
            Marker(
              point: latLngs.last,
              width: 30,
              height: 30,
              child: const Icon(Icons.flag, color: AppColors.red, size: 30),
            ),
          ],
        ),
      ],
    );
  }
}
