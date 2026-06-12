import 'package:flutter/material.dart';

class AppColors {
  // Plime brand
  static const mint = Color(0xFF5EEAD4);
  static const mintDark = Color(0xFF2DD4BF);
  static const purple = Color(0xFFA78BFA);
  static const blue = Color(0xFF60A5FA);
  static const accent = Color(0xFF5EEAD4);
  static const accentLight = Color(0xFF99F6E4);

  static const lightBg = Color(0xFFF8FAFC);
  static const lightCard = Colors.white;
  static const lightText = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightProgressBg = Color(0xFFE2E8F0);

  static const darkBg = Color(0xFF0A0A0F);
  static const darkCard = Color(0xFF16161F);
  static const darkCardElevated = Color(0xFF1E1E2A);
  static const darkText = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF2A2A3A);
  static const darkProgressBg = Color(0xFF252532);

  static const chartGradient = [
    Color(0xFF5EEAD4),
    Color(0xFF60A5FA),
  ];

  static const chartPurple = Color(0xFFA78BFA);
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fill = isDark ? AppColors.darkCardElevated : AppColors.lightBg;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mint,
        brightness: brightness,
        primary: AppColors.mint,
        secondary: AppColors.purple,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        indicatorColor: AppColors.mint.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? AppColors.mint
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        bodyMedium: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        titleLarge: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
