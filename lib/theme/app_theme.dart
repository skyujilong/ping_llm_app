import 'package:flutter/material.dart';

/// Design tokens matching the HTML prototype.
class AppColors {
  AppColors._();
  static const Color bg = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fg = Color(0xFF1C1C1E);
  static const Color muted = Color(0xFF8E8E93);
  static const Color border = Color(0xFFE5E5EA);
  static const Color accent = Color(0xFF007AFF);
  static const Color success = Color(0xFF34C759);
  static const Color warn = Color(0xFFFF9500);
  static const Color danger = Color(0xFFFF3B30);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      surface: AppColors.surface,
      primary: AppColors.accent,
      error: AppColors.danger,
      outline: AppColors.border,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.fg,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.02,
        color: AppColors.fg,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentTextStyle: TextStyle(fontWeight: FontWeight.w500),
    ),
    fontFamily: '.SF Pro Text',
  );
}
