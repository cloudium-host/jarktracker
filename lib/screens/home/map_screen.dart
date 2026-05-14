import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/map_style.dart';
import '../../core/time_format.dart';
import '../../models/device_map_item.dart';
import '../../services/devices_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/device_thumb.dart';
import '../../widgets/map_style_sheet.dart';
import '../../widgets/share_device_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.focusDeviceId, this.onClearFocus});

  /// When non-null, only this device is rendered and the map is framed to it.
  final int? focusDeviceId;
  final VoidCallback? onClearFocus;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapCtrl = MapController();
  List<DeviceMapItem> _devices = [];
  bool _loading = true;
  Object? _error;
  Timer? _timer;
  bool _initialCentered = false;

  @override
  void initState() {
    super.initState();
    _load(initial: true);
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _load(silent: true));
  }

  @override
  void didUpdateWidget(covariant MapScreen old) {
    super.didUpdateWidget(old);
    if (widget.focusDeviceId != old.focusDeviceId) {
      // Re-frame for the new focus target (or reset).
      _centerOnSelection(animate: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Iterable<DeviceMapItem> get _visible {
    if (widget.focusDeviceId == null) return _devices;
    return _devices.where((d) => d.id == widget.focusDeviceId);
  }

  Future<void> _load({bool silent = false, bool initial = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final items = await DevicesService().map();
      if (!mounted) return;
      setState(() {
        _devices = items;
        _loading = false;
        _error = null;
      });
      if (initial && !_initialCentered) {
        _initialCentered = true;
        _centerOnSelection();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  void _centerOnSelection({bool animate = false}) {
    final list = _visible.where((d) => d.lat != null && d.lng != null).toList();
    if (list.isEmpty) return;
    if (list.length == 1) {
      _mapCtrl.move(LatLng(list.first.lat!, list.first.lng!), 16);
      return;
    }
    final lats = list.map((d) => d.lat!).toList();
    final lngs = list.map((d) => d.lng!).toList();
    final south = lats.reduce((a, b) => a < b ? a : b);
    final north = lats.reduce((a, b) => a > b ? a : b);
    final west = lngs.reduce((a, b) => a < b ? a : b);
    final east = lngs.reduce((a, b) => a > b ? a : b);
    _mapCtrl.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(LatLng(south, west), LatLng(north, east)),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  List<Marker> _buildMarkers() => _visible
      .where((d) => d.lat != null && d.lng != null)
      .map(
        (d) => Marker(
          point: LatLng(d.lat!, d.lng!),
          width: 56,
          height: 64,
          child: _DeviceMarker(device: d),
        ),
      )
      .toList();

  List<Polyline> _buildTails() => _visible
      .where((d) => d.tail.length >= 2)
      .map(
        (d) => Polyline(
          points: d.tail.map((p) => LatLng(p.lat, p.lng)).toList(),
          strokeWidth: 3,
          color: AppColors.red,
        ),
      )
      .toList();

  DeviceMapItem? get _focusedDevice {
    if (widget.focusDeviceId == null) return null;
    for (final d in _devices) {
      if (d.id == widget.focusDeviceId) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusDeviceId != null;
    final total = _devices.length;
    final visibleCount = _visible.length;
    final focusedDevice = _focusedDevice;
    return Stack(
      children: [
        ValueListenableBuilder<MapStyle>(
          valueListenable: MapStyleController.instance,
          builder: (_, style, __) {
            return FlutterMap(
              mapController: _mapCtrl,
              options: const MapOptions(
                initialCenter: LatLng(-2.1709, -79.9224), // Guayaquil
                initialZoom: 12,
                minZoom: 3,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate: style.urlTemplate,
                  subdomains: style.subdomains,
                  maxNativeZoom: style.maxNativeZoom,
                  userAgentPackageName: 'com.jarkenterprises.jarktracker',
                ),
                PolylineLayer(polylines: _buildTails()),
                MarkerLayer(markers: _buildMarkers()),
              ],
            );
          },
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderBar(
                    total: total,
                    visible: visibleCount,
                    loading: _loading,
                    error: _error,
                    focused: focused,
                    onReload: _load,
                    onClearFocus: widget.onClearFocus,
                  ),
                  if (focused && focusedDevice != null) ...[
                    const SizedBox(height: 8),
                    _FocusedDeviceCard(device: focusedDevice),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FocusedDeviceCard extends StatelessWidget {
  const _FocusedDeviceCard({required this.device});
  final DeviceMapItem device;

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy.withOpacity(0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DeviceThumb(
                iconUrl: device.icon.url,
                size: 48,
                borderColor: _statusColor,
                background: AppColors.navyLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => ShareDeviceSheet.show(
                  context,
                  deviceId: device.id,
                  deviceName: device.name,
                ),
                icon: const Icon(Icons.share, color: Colors.white),
                tooltip: 'Compartir',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.qr_code_2,
            label: 'IMEI',
            value: device.imei,
          ),
          _InfoLine(
            icon: Icons.circle,
            iconColor: _statusColor,
            label: 'Estado',
            value: device.status.title,
            valueColor: _statusColor,
          ),
          _InfoLine(
            icon: Icons.speed,
            label: 'Velocidad',
            value: device.speed.human,
          ),
          _InfoLine(
            icon: Icons.access_time,
            label: 'Sincronización',
            value: formatTimestampRaw(device.time?.timestamp),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? Colors.white54),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? Colors.white,
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

class _DeviceMarker extends StatelessWidget {
  const _DeviceMarker({required this.device});
  final DeviceMapItem device;

  Color get _color {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _color, width: 1),
          ),
          child: Text(
            device.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 2),
        DeviceThumb(
          iconUrl: device.icon.url,
          size: 38,
          borderColor: _color,
          background: AppColors.navy,
          borderRadius: 19, // circular
        ),
      ],
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.total,
    required this.visible,
    required this.loading,
    required this.error,
    required this.focused,
    required this.onReload,
    required this.onClearFocus,
  });
  final int total;
  final int visible;
  final bool loading;
  final Object? error;
  final bool focused;
  final VoidCallback onReload;
  final VoidCallback? onClearFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navy.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.gps_fixed, color: AppColors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error != null
                  ? 'Error cargando'
                  : loading
                      ? 'Cargando...'
                      : focused
                          ? 'Siguiendo 1 de $total'
                          : '$total dispositivo${total == 1 ? '' : 's'}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          if (focused && onClearFocus != null)
            IconButton(
              onPressed: onClearFocus,
              icon: const Icon(Icons.close, color: Colors.white),
              visualDensity: VisualDensity.compact,
              tooltip: 'Ver todos',
            ),
          IconButton(
            onPressed: () => MapStyleSheet.show(context),
            icon: const Icon(Icons.layers, color: Colors.white),
            visualDensity: VisualDensity.compact,
            tooltip: 'Cambiar mapa',
          ),
          IconButton(
            onPressed: onReload,
            icon: const Icon(Icons.refresh, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
