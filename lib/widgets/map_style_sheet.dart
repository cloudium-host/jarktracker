import 'package:flutter/material.dart';
import '../core/map_style.dart';
import '../theme/app_theme.dart';

class MapStyleSheet extends StatelessWidget {
  const MapStyleSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const MapStyleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ValueListenableBuilder<MapStyle>(
          valueListenable: MapStyleController.instance,
          builder: (_, current, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.layers, color: AppColors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Capa de mapa',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final style in kMapStyles)
                  _StyleTile(
                    style: style,
                    selected: style.id == current.id,
                    onTap: () async {
                      await MapStyleController.instance.setStyle(style);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final MapStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.red.withOpacity(0.12)
              : palette.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.red : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              style.icon,
              color: selected ? AppColors.red : palette.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                style.label,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.red, size: 20),
          ],
        ),
      ),
    );
  }
}
