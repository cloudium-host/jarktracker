import 'package:flutter/material.dart';
import '../services/commands_service.dart';
import '../theme/app_theme.dart';

/// Contextual nav bar shown when the map is focused on a single device.
/// First slot = "Mapa" pill (same look as the main nav bar active tab) that
/// exits focus mode and returns to viewing all devices. The remaining four
/// slots are circular command buttons with a label below each icon.
class CommandsNavBar extends StatefulWidget {
  const CommandsNavBar({
    super.key,
    required this.deviceId,
    required this.onExitFocus,
  });

  final int deviceId;
  final VoidCallback onExitFocus;

  @override
  State<CommandsNavBar> createState() => _CommandsNavBarState();
}

class _CommandsNavBarState extends State<CommandsNavBar> {
  final Set<String> _inFlight = {};

  Future<void> _send(String type, String label) async {
    if (_inFlight.contains(type)) return;
    setState(() => _inFlight.add(type));
    final result = await CommandsService().send(
      deviceId: widget.deviceId,
      type: type,
    );
    if (!mounted) return;
    setState(() => _inFlight.remove(type));
    final bg = result.ok ? AppColors.online : AppColors.offline;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label: ${result.message}'),
        backgroundColor: bg,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Container(
          height: 84,
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              // Slot 1 — "Mapa" pill (same style as the main nav bar active tab)
              Expanded(
                flex: 3,
                child: _MapaPill(onTap: widget.onExitFocus),
              ),
              // Slots 2-5 — action buttons with label below icon
              Expanded(
                flex: 2,
                child: _CommandButton(
                  icon: Icons.lock,
                  label: 'Bloquear\nmotor',
                  color: AppColors.red,
                  loading: _inFlight.contains('engineStop'),
                  onTap: () => _send('engineStop', 'Bloquear motor'),
                ),
              ),
              Expanded(
                flex: 2,
                child: _CommandButton(
                  icon: Icons.lock_open,
                  label: 'Desbloq.\nmotor',
                  color: AppColors.online,
                  loading: _inFlight.contains('engineResume'),
                  onTap: () => _send('engineResume', 'Desbloquear motor'),
                ),
              ),
              Expanded(
                flex: 2,
                child: _CommandButton(
                  icon: Icons.meeting_room_outlined,
                  label: 'Abrir\npuertas',
                  color: const Color(0xFF3B82F6),
                  loading: _inFlight.contains('doorOpen'),
                  onTap: () => _send('doorOpen', 'Abrir puertas'),
                ),
              ),
              Expanded(
                flex: 2,
                child: _CommandButton(
                  icon: Icons.door_front_door_outlined,
                  label: 'Cerrar\npuertas',
                  color: const Color(0xFF7C3AED),
                  loading: _inFlight.contains('doorClose'),
                  onTap: () => _send('doorClose', 'Cerrar puertas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapaPill extends StatelessWidget {
  const _MapaPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(28),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.home_outlined, color: Colors.white, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Mapa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  const _CommandButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.2),
                ),
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
