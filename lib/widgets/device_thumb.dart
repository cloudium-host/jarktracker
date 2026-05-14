import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable device thumbnail. Tries to load the user-assigned icon from the
/// GPS-Wox backend (same URL used on the web admin). Falls back to a local
/// car glyph if the URL is missing or the network image fails.
class DeviceThumb extends StatelessWidget {
  const DeviceThumb({
    super.key,
    required this.iconUrl,
    required this.size,
    this.borderColor,
    this.borderRadius = 10,
    this.background,
  });

  final String? iconUrl;
  final double size;
  final Color? borderColor;
  final double borderRadius;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final bg = background ?? AppColors.navyLight;
    final border = borderColor ?? AppColors.darkCardBorder;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: _buildInner(size),
      ),
    );
  }

  Widget _buildInner(double s) {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return _fallback(s);
    }
    return Image.network(
      iconUrl!,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallback(s),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
          ),
        );
      },
    );
  }

  Widget _fallback(double s) =>
      Icon(Icons.directions_car, size: s * 0.55, color: Colors.white54);
}
