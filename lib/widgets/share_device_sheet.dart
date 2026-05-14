import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/sharing_service.dart';
import '../theme/app_theme.dart';

class ShareDeviceSheet extends StatefulWidget {
  const ShareDeviceSheet({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  final int deviceId;
  final String deviceName;

  static Future<void> show(
    BuildContext context, {
    required int deviceId,
    required String deviceName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ShareDeviceSheet(deviceId: deviceId, deviceName: deviceName),
    );
  }

  @override
  State<ShareDeviceSheet> createState() => _ShareDeviceSheetState();
}

class _ShareDeviceSheetState extends State<ShareDeviceSheet> {
  int? _selectedMinutes = 60;
  bool _busy = false;
  String? _resultUrl;
  String? _error;

  static const _options = <_DurationOption>[
    _DurationOption(label: 'Sin caducidad', minutes: null),
    _DurationOption(label: '30 minutos', minutes: 30),
    _DurationOption(label: '1 hora', minutes: 60),
    _DurationOption(label: '24 horas', minutes: 60 * 24),
    _DurationOption(label: '7 días', minutes: 60 * 24 * 7),
  ];

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final sharing = await SharingService()
          .create(deviceId: widget.deviceId, expirationMinutes: _selectedMinutes);
      setState(() {
        _resultUrl = sharing.url;
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo generar el enlace: $e';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _resultUrl == null
              ? _buildSelector(palette)
              : _buildResult(palette),
        ),
      ),
    );
  }

  Widget _buildSelector(AppPalette palette) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.share, color: AppColors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Compartir ${widget.deviceName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Genera un enlace temporal con la ubicación en vivo de este dispositivo. '
          'Cualquiera con el enlace podrá verla mientras esté activo.',
          style: TextStyle(color: palette.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 14),
        Text(
          'Duración del enlace',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final opt in _options)
              ChoiceChip(
                label: Text(opt.label),
                selected: _selectedMinutes == opt.minutes,
                onSelected: (_) =>
                    setState(() => _selectedMinutes = opt.minutes),
                selectedColor: AppColors.red,
                labelStyle: TextStyle(
                  color: _selectedMinutes == opt.minutes
                      ? Colors.white
                      : palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: palette.background,
                side: BorderSide.none,
              ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.link),
                label: const Text(
                  'Generar enlace',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResult(AppPalette palette) {
    final url = _resultUrl!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.online),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Enlace listo',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  url,
                  style: TextStyle(color: palette.textPrimary, fontSize: 12),
                  maxLines: 2,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enlace copiado')),
                  );
                },
                icon: Icon(Icons.copy, color: palette.textSecondary),
                tooltip: 'Copiar',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Cerrar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textSecondary,
                  side: BorderSide(color: palette.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Share.share(
                    'Ubicación de ${widget.deviceName}: $url',
                    subject: 'Compartir ubicación',
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text(
                  'Compartir',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DurationOption {
  const _DurationOption({required this.label, required this.minutes});
  final String label;
  final int? minutes;
}
