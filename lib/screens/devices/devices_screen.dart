import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../services/devices_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/device_card.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key, this.onDeviceTap});

  /// Called when the user taps on a device card in the list. The shell uses
  /// this to switch to the map tab and focus on the selected device.
  final ValueChanged<int>? onDeviceTap;

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late Future<List<Device>> _future;

  @override
  void initState() {
    super.initState();
    _future = DevicesService().list();
  }

  Future<void> _refresh() async {
    final next = DevicesService().list();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      color: palette.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.devices_other, color: palette.textPrimary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Mis dispositivos',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Device>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: palette.textPrimary),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Error cargando dispositivos:\n${snap.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: palette.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refresh,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final items = snap.data ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'Sin dispositivos',
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.red,
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: items.length,
                      itemBuilder: (_, i) => DeviceCard(
                        device: items[i],
                        onTap: () => widget.onDeviceTap?.call(items[i].id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
