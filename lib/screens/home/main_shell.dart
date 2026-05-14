import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/commands_nav_bar.dart';
import '../devices/devices_screen.dart';
import '../history/history_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'map_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Tab order: Equipos, Historial, Mapa (home, center), Alertas, Perfil.
  static const int _mapTabIndex = 2;

  int _index = _mapTabIndex;
  int? _focusDeviceId;

  void _goToDeviceOnMap(int deviceId) {
    setState(() {
      _focusDeviceId = deviceId;
      _index = _mapTabIndex;
    });
  }

  void _clearMapFocus() {
    if (_focusDeviceId != null) {
      setState(() => _focusDeviceId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final pages = <Widget>[
      DevicesScreen(onDeviceTap: _goToDeviceOnMap),
      const HistoryScreen(),
      MapScreen(focusDeviceId: _focusDeviceId, onClearFocus: _clearMapFocus),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
    // When the map tab is focused on a single device, replace the regular
    // tab bar with a contextual action bar showing engine / door commands.
    final showCommandsBar =
        _focusDeviceId != null && _index == _mapTabIndex;
    return Scaffold(
      extendBody: true,
      backgroundColor: palette.background,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: showCommandsBar
          ? CommandsNavBar(
              deviceId: _focusDeviceId!,
              onExitFocus: _clearMapFocus,
            )
          : _NavBar(
              index: _index,
              onChanged: (i) {
                if (i != _mapTabIndex) _clearMapFocus();
                setState(() => _index = i);
              },
            ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

const _items = <_NavItemData>[
  _NavItemData(icon: Icons.directions_car_filled_outlined, label: 'Equipos'),
  _NavItemData(icon: Icons.timeline, label: 'Historial'),
  _NavItemData(icon: Icons.home_outlined, label: 'Mapa'),
  _NavItemData(icon: Icons.notifications_outlined, label: 'Alertas'),
  _NavItemData(icon: Icons.person_outline, label: 'Perfil'),
];

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            // Navbar is always navy regardless of theme
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          // Every tab slot has equal width so the icon centers stay at a
          // fixed distance from each other regardless of which tab is
          // active. The active pill grows visually inside its own slot and
          // its content is scaled to fit via FittedBox (see _NavItem).
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    data: _items[i],
                    active: index == i,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.data, required this.active, required this.onTap});
  final _NavItemData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Fixed padding (no implicit animation on size) + clipping + FittedBox so
    // any transient width mismatch during tab transitions never overflows.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.red : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    data.icon,
                    color: active ? Colors.white : Colors.white70,
                    size: 22,
                  ),
                  if (active) ...[
                    const SizedBox(width: 6),
                    Text(
                      data.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
