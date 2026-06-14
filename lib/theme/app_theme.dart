import 'package:flutter/material.dart';

/// Flowbite + October CMS inspired design tokens for Plime.
class AppColors {
  // Flowbite primary (blue)
  static const primary = Color(0xFF1C64F2);
  static const primaryDark = Color(0xFF1A56DB);
  static const primaryLight = Color(0xFFE1EFFE);

  // Plime accent (teal / mint from screenshots)
  static const mint = Color(0xFF14B8A6);
  static const mintDark = Color(0xFF0D9488);
  static const mintLight = Color(0xFFCCFBF1);
  static const accent = mint;
  static const accentLight = mintLight;

  // October warm accent
  static const october = Color(0xFFD97706);
  static const octoberLight = Color(0xFFFEF3C7);

  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFEDE9FE);
  static const blue = Color(0xFF3B82F6);
  static const rose = Color(0xFFF43F5E);

  // Flowbite gray scale — light
  static const lightBg = Color(0xFFF9FAFB);
  static const lightCard = Colors.white;
  static const lightText = Color(0xFF111827);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightBorder = Color(0xFFE5E7EB);
  static const lightProgressBg = Color(0xFFE5E7EB);
  static const lightInputBg = Color(0xFFF3F4F6);

  // Flowbite gray scale — dark
  static const darkBg = Color(0xFF111827);
  static const darkCard = Color(0xFF1F2937);
  static const darkCardElevated = Color(0xFF374151);
  static const darkText = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkBorder = Color(0xFF374151);
  static const darkProgressBg = Color(0xFF374151);
  static const darkInputBg = Color(0xFF374151);

  static const chartGradient = [mint, blue];
  static const chartPurple = purple;
}

class AppDecorations {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static BoxDecoration card(BuildContext context, {Color? accent}) {
    final dark = isDark(context);
    return BoxDecoration(
      color: dark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: accent?.withValues(alpha: 0.35) ??
            (dark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      boxShadow: dark
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  static BoxDecoration heroGradient(BuildContext context) {
    final dark = isDark(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                const Color(0xFF134E4A),
                AppColors.darkCard,
                const Color(0xFF1E1B4B),
              ]
            : [
                AppColors.mintLight,
                Colors.white,
                AppColors.primaryLight,
              ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.mint.withValues(alpha: dark ? 0.35 : 0.45),
      ),
      boxShadow: dark
          ? null
          : [
              BoxShadow(
                color: AppColors.mint.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
    );
  }

  static BoxDecoration badge(Color color, {bool dark = false}) {
    return BoxDecoration(
      color: color.withValues(alpha: dark ? 0.2 : 0.12),
      borderRadius: BorderRadius.circular(6),
    );
  }
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fill = isDark ? AppColors.darkInputBg : AppColors.lightInputBg;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.mint,
        tertiary: AppColors.purple,
        surface: card,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black26,
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
            size: 22,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.darkText : AppColors.lightText,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fill,
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontWeight: FontWeight.w800,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
