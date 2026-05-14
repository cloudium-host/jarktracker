import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme_controller.dart';
import '../../models/user.dart';
import '../../services/api_client.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? _user;
  bool _loading = true;
  Object? _error;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await UserService().get();
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await ApiClient.instance.clearTokens();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final updated = await UserService().uploadAvatar(File(picked.path));
      if (!mounted) return;
      setState(() {
        _user = updated;
        _uploadingAvatar = false;
      });
      _snack('Foto actualizada');
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      _snack('Error subiendo la foto: $e');
    }
  }

  Future<void> _editPhone() async {
    final ctrl = TextEditingController(text: _user?.phoneNumber ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.of(ctx).card,
        title: Text('Teléfono', style: TextStyle(color: AppPalette.of(ctx).textPrimary)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(hintText: '+593 99 999 9999'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result == null) return;
    try {
      final updated = await UserService().updatePhone(result);
      if (!mounted) return;
      setState(() => _user = updated);
      _snack('Teléfono actualizado');
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.of(ctx).card,
        title: Text('Cambiar contraseña', style: TextStyle(color: AppPalette.of(ctx).textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(hintText: 'Contraseña actual'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(hintText: 'Nueva contraseña'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(hintText: 'Confirmar nueva'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (newCtrl.text.length < 6) return;
              if (newCtrl.text != confirmCtrl.text) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await UserService().updatePassword(
        current: currentCtrl.text,
        next: newCtrl.text,
      );
      _snack('Contraseña actualizada');
    } catch (e) {
      _snack('Error: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.navy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      color: palette.background,
      child: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: palette.textPrimary))
            : (_error != null || _user == null)
                ? _ErrorFallback(
                    onLogout: _logout,
                    onRetry: _load,
                    message: '${_error ?? "sin datos"}',
                  )
                : _buildContent(palette),
      ),
    );
  }

  Widget _buildContent(AppPalette palette) {
    final user = _user!;
    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _Avatar(
            url: user.avatarUrl,
            uploading: _uploadingAvatar,
            onTap: _pickAvatar,
            palette: palette,
          ),
          const SizedBox(height: 12),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _LicenseCard(subscription: user.subscription, palette: palette),
          const SizedBox(height: 20),
          _SectionTitle('Datos de contacto', palette: palette),
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.phone,
            label: 'Teléfono',
            value: user.phoneNumber.isEmpty ? 'Agregar' : user.phoneNumber,
            onTap: _editPhone,
            palette: palette,
          ),
          _ActionRow(
            icon: Icons.email,
            label: 'Email (no editable)',
            value: user.email,
            palette: palette,
          ),
          const SizedBox(height: 20),
          _SectionTitle('Seguridad', palette: palette),
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.lock,
            label: 'Cambiar contraseña',
            value: '••••••••',
            onTap: _changePassword,
            palette: palette,
          ),
          const SizedBox(height: 20),
          _SectionTitle('Preferencias', palette: palette),
          const SizedBox(height: 8),
          _ThemeSwitchTile(palette: palette),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.uploading,
    required this.onTap,
    required this.palette,
  });
  final String? url;
  final bool uploading;
  final VoidCallback onTap;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: uploading ? null : onTap,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: palette.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.red, width: 3),
              ),
              child: ClipOval(
                child: uploading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.red),
                      )
                    : (url != null && url!.isNotEmpty
                        ? Image.network(
                            url!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.person, size: 60, color: palette.textSecondary),
                          )
                        : Icon(Icons.person, size: 60, color: palette.textSecondary)),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: uploading ? null : onTap,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.background, width: 2),
                ),
                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseCard extends StatelessWidget {
  const _LicenseCard({required this.subscription, required this.palette});
  final Subscription subscription;
  final AppPalette palette;

  String get _title => subscription.permanent ? 'Licencia' : 'Licencia activa';

  String get _value {
    if (subscription.permanent) return 'Permanente';
    final d = subscription.daysRemaining;
    if (d == null) return '—';
    if (d < 0) return 'Expirada hace ${-d} días';
    if (d == 0) return 'Expira hoy';
    if (d == 1) return 'Expira mañana';
    return 'Quedan $d días';
  }

  Color get _accent {
    if (subscription.permanent) return AppColors.online;
    final d = subscription.daysRemaining;
    if (d == null || d < 0) return AppColors.offline;
    if (d < 7) return AppColors.idle;
    return AppColors.online;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user, color: _accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title,
                    style: TextStyle(color: palette.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  _value,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.palette});
  final String text;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: palette.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.palette,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final AppPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: palette.textSecondary, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(color: palette.textSecondary, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: palette.textPrimary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right, color: palette.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSwitchTile extends StatelessWidget {
  const _ThemeSwitchTile({required this.palette});
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (_, mode, __) {
        final isDark = mode == ThemeMode.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: palette.textPrimary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tema ${isDark ? "oscuro" : "claro"}',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isDark ? 'Apariencia nocturna' : 'Apariencia diurna',
                      style: TextStyle(color: palette.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isDark,
                activeColor: AppColors.red,
                onChanged: (_) => ThemeController.instance.toggle(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorFallback extends StatelessWidget {
  const _ErrorFallback({
    required this.onLogout,
    required this.onRetry,
    required this.message,
  });
  final VoidCallback onLogout;
  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_off, size: 64, color: palette.textSecondary),
          const SizedBox(height: 12),
          Text('Error: $message', style: TextStyle(color: palette.textSecondary)),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
