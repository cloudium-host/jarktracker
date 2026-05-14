import 'package:flutter/material.dart';
import '../core/time_format.dart' show formatTimestampRaw;
import '../models/device.dart';
import '../theme/app_theme.dart';
import 'device_thumb.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.device, this.onTap});
  final Device device;
  final VoidCallback? onTap;

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _Thumb(device: device),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'IMEI ${device.imei}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            device.status.title,
                            style: TextStyle(color: _statusColor, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.speed, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            device.speed.human,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatTimestampRaw(device.time?.timestamp),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.device});
  final Device device;

  @override
  Widget build(BuildContext context) {
    return DeviceThumb(iconUrl: device.icon.url, size: 62);
  }
}
