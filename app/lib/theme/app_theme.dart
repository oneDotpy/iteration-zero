// lib/theme/app_theme.dart
// Re-export app_colors.dart so that existing screens that import app_theme.dart
// and reference AppColors.caregiverPrimary etc. continue to work.
export 'app_colors.dart';

import 'package:flutter/material.dart';
import 'app_colors.dart';

// AppTheme provides light and dark ThemeData.
// The new AppColors class in app_colors.dart is also imported here.

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colors = AppColors.light();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colors.primary,
        onPrimary: Colors.white,
        primaryContainer: colors.primaryLight,
        onPrimaryContainer: colors.textHigh,
        secondary: colors.sage,
        onSecondary: Colors.white,
        secondaryContainer: colors.surfaceAlt,
        onSecondaryContainer: colors.textHigh,
        error: const Color(0xFFE57373),
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.textHigh,
        outline: colors.border,
        outlineVariant: colors.border,
        surfaceContainerHighest: colors.surfaceAlt,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: TextStyle(color: colors.textMed.withValues(alpha: 0.6)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: colors.textHigh,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: colors.textHigh),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: colors.textHigh,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: colors.textHigh,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colors.textHigh,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colors.textHigh,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: colors.textHigh,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.textHigh,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textHigh,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colors.textHigh,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: colors.textHigh,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: colors.textMed,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textHigh,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.textHigh,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData dark() {
    final colors = AppColors.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: colors.primary,
        onPrimary: const Color(0xFF16181C),
        primaryContainer: colors.primaryLight,
        onPrimaryContainer: colors.textHigh,
        secondary: colors.sage,
        onSecondary: const Color(0xFF16181C),
        secondaryContainer: colors.surfaceAlt,
        onSecondaryContainer: colors.textHigh,
        error: const Color(0xFFEF9A9A),
        onError: const Color(0xFF16181C),
        surface: colors.surface,
        onSurface: colors.textHigh,
        outline: colors.border,
        outlineVariant: colors.border,
        surfaceContainerHighest: colors.surfaceAlt,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: const Color(0xFF16181C),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: TextStyle(color: colors.textMed.withValues(alpha: 0.6)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: colors.textHigh,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: colors.textHigh),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: colors.textHigh,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: colors.textHigh,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colors.textHigh,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colors.textHigh,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: colors.textHigh,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.textHigh,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textHigh,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colors.textHigh,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: colors.textHigh,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: colors.textMed,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textHigh,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceAlt,
        contentTextStyle: TextStyle(color: colors.textHigh),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 0,
      ),
    );
  }
}

