import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const red = Color(0xFFE30613);
  static const redDark = Color(0xFFB30510);

  // Dark palette
  static const navy = Color(0xFF0A0E2A);
  static const navyLight = Color(0xFF141A3E);
  static const darkTextPrimary = Colors.white;
  static const darkTextSecondary = Color(0xFFB0B6C8);
  static const darkCardBorder = Color(0xFF2D344F);

  // Light palette
  static const lightBg = Color(0xFFF5F6FA);
  static const lightCard = Colors.white;
  static const lightTextPrimary = Color(0xFF0A0E2A);
  static const lightTextSecondary = Color(0xFF5B627A);
  static const lightCardBorder = Color(0xFFE1E4EC);

  // Status
  static const online = Color(0xFF22C55E);
  static const offline = Color(0xFFEF4444);
  static const idle = Color(0xFFF59E0B);

  // Legacy aliases used before the split (kept working in dark theme).
  static const textPrimary = darkTextPrimary;
  static const textSecondary = darkTextSecondary;
  static const cardBorder = darkCardBorder;
}

/// Helper to read semantic colors that depend on current brightness.
class AppPalette {
  AppPalette._(this.isDark);
  final bool isDark;

  static AppPalette of(BuildContext context) =>
      AppPalette._(Theme.of(context).brightness == Brightness.dark);

  Color get background => isDark ? AppColors.navy : AppColors.lightBg;
  Color get card => isDark ? AppColors.navyLight : AppColors.lightCard;
  Color get border => isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;
  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get navBg => isDark ? const Color(0xFF0F1430) : Colors.white;
}

class AppTheme {
  static InputDecorationTheme _inputTheme({required bool dark}) {
    final fill = dark ? Colors.white : AppColors.lightBg;
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: dark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: dark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 2),
      ),
      hintStyle: GoogleFonts.jetBrainsMono(color: Colors.black54),
      labelStyle: GoogleFonts.jetBrainsMono(color: Colors.black87),
    );
  }

  static ElevatedButtonThemeData _buttonTheme() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navy,
      primaryColor: AppColors.red,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        secondary: AppColors.red,
        surface: AppColors.navy,
      ),
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      inputDecorationTheme: _inputTheme(dark: true),
      elevatedButtonTheme: _buttonTheme(),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.red,
      colorScheme: const ColorScheme.light(
        primary: AppColors.red,
        secondary: AppColors.red,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
      inputDecorationTheme: _inputTheme(dark: false),
      elevatedButtonTheme: _buttonTheme(),
    );
  }
}
