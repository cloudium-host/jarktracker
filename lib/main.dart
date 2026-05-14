import 'package:flutter/material.dart';
import 'core/config.dart';
import 'core/map_style.dart';
import 'core/theme_controller.dart';
import 'screens/login/login_screen.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';
import 'screens/home/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  await MapStyleController.instance.load();
  runApp(const JarkTrackerApp());
}

class JarkTrackerApp extends StatelessWidget {
  const JarkTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (_, mode, __) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const _Bootstrap(),
        );
      },
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final token = await ApiClient.instance.getAccessToken();
    setState(() {
      _loggedIn = token != null && token.isNotEmpty;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      final palette = AppPalette.of(context);
      return Scaffold(
        backgroundColor: palette.background,
        body: Center(child: CircularProgressIndicator(color: palette.textPrimary)),
      );
    }
    return _loggedIn ? const MainShell() : const LoginScreen();
  }
}
