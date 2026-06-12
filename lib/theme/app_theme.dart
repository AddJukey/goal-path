import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFFF5A623);
  static const accentLight = Color(0xFFF7B84D);

  static const lightBg = Color(0xFFF4F7FC);
  static const lightCard = Colors.white;
  static const lightText = Color(0xFF0F2B3D);
  static const lightTextSecondary = Color(0xFF4A6A85);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightProgressBg = Color(0xFFE2E8F0);

  static const darkBg = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
  static const darkText = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkBorder = Color(0xFF334155);
  static const darkProgressBg = Color(0xFF2D3A4E);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightText),
        bodyMedium: TextStyle(color: AppColors.lightText),
        labelSmall: TextStyle(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkText),
        labelSmall: TextStyle(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
