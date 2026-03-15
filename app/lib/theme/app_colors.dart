// lib/theme/app_colors.dart
import 'package:flutter/material.dart';
import '../app_state.dart';

class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color primary;
  final Color primaryLight;
  final Color rose;
  final Color roseLight;
  final Color sage;
  final Color sageLight;
  final Color teal;
  final Color tealLight;
  final Color softPurple;
  final Color softPurpleLight;
  final Color textHigh;
  final Color textMed;
  final Color textLow;
  final Color border;
  // Instance situation bg colors (theme-aware, Bg suffix avoids conflict
  // with the static const situationTime/Location/Person/Confused below)
  final Color situationTimeBg;
  final Color situationLocationBg;
  final Color situationPersonBg;
  final Color situationConfusedBg;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.primaryLight,
    required this.rose,
    required this.roseLight,
    required this.sage,
    required this.sageLight,
    required this.teal,
    required this.tealLight,
    required this.softPurple,
    required this.softPurpleLight,
    required this.textHigh,
    required this.textMed,
    required this.textLow,
    required this.border,
    required this.situationTimeBg,
    required this.situationLocationBg,
    required this.situationPersonBg,
    required this.situationConfusedBg,
  });

  // Instance card shadow getter — named `shadow` to avoid conflict with
  // the static `cardShadow` getter below.
  BoxShadow get shadow => BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

    static AppColors light() => const AppColors(
      background: Color.fromARGB(255, 250, 249, 243),
      surface: Colors.white,
      surfaceAlt: Color(0xFFE7E1CF),
      primary: Color(0xFF7E99B4),
      primaryLight: Color(0xFFE4ECF4),
      rose: Color(0xFFCE9482),
      roseLight: Color.fromARGB(255, 242, 231, 225),
      sage: Color(0xFFB0C29D),
      sageLight: Color.fromARGB(255, 231, 238, 224),
      teal: Color(0xFF8FB0A3),
      tealLight: Color.fromARGB(255, 227, 239, 231),
      softPurple: Color(0xFF9B8EC4),
      softPurpleLight: Color(0xFFF1EDFA),
      textHigh: Color(0xFF3F4A3C),
      textMed: Color(0xFF6B7566),
      textLow: Color(0xFF98A28F),
      border: Color(0xFFDAD4C1),
      situationTimeBg: Color(0xFFE3F0EC),
      situationLocationBg: Color(0xFFE7EEDD),
      situationPersonBg: Color(0xFFF2E5E1),
      situationConfusedBg: Color(0xFFE4ECF4),
      );

  static AppColors dark() => const AppColors(
        background: Color(0xFF16181C),
        surface: Color(0xFF22262E),
        surfaceAlt: Color(0xFF2A2F39),
        primary: Color.fromARGB(255, 67, 105, 139),
        primaryLight: Color.fromARGB(255, 29, 36, 42),
        rose: Color.fromARGB(255, 146, 81, 61),
        roseLight: Color.fromARGB(255, 34, 30, 30),
        sage: Color.fromARGB(255, 99, 118, 79),
        sageLight: Color.fromARGB(255, 28, 34, 30),
        teal: Color.fromARGB(255, 64, 104, 88),
        tealLight: Color.fromARGB(255, 27, 34, 36),
        softPurple: Color(0xFF9B8EC4),
        softPurpleLight: Color(0xFFF1EDFA),
        textHigh: Color(0xFFF0EDE8),
        textMed: Color(0xFFA0A8B0),
        textLow: Color(0xFF5A6070),
        border: Color(0xFF2E3340),
        situationTimeBg: Color(0xFF2E2A14),
        situationLocationBg: Color(0xFF1A2E1A),
        situationPersonBg: Color(0xFF261A2E),
        situationConfusedBg: Color(0xFF162230),
      );

  static AppColors highContrast() => const AppColors(
        background: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        surfaceAlt: Color(0xFFEEEEEE),
        primary: Color.fromARGB(255, 48, 82, 151),
        primaryLight: Color.fromARGB(255, 251, 253, 255),
        rose: Color.fromARGB(255, 149, 48, 18),
        roseLight: Color.fromARGB(255, 255, 248, 248),
        sage: Color.fromARGB(255, 57, 123, 46),
        sageLight: Color.fromARGB(255, 246, 253, 246),
        teal: Color.fromARGB(255, 30, 132, 108),
        tealLight: Color.fromARGB(255, 249, 255, 254),
        softPurple: Color(  0xFF9B8EC4),
        softPurpleLight: Color(0xFFF1EDFA),
        textHigh: Color(0xFF000000),
        textMed: Color(0xFF1A1A1A),
        textLow: Color(0xFF444444),
        border: Color(0xFF000000),
        situationTimeBg: Color(0xFFFFE680),
        situationLocationBg: Color(0xFFB8E0B8),
        situationPersonBg: Color(0xFFD9B8E8),
        situationConfusedBg: Color(0xFFB8D8F0),
      );

  // ── Backwards-compat static constants (light values) ──────────────────────
  // Referenced by the protected screens that must not be modified.
  static const caregiverPrimary = Color(0xFF7E99B4);
  static const caregiverLightBg = Color(0xFFE4ECF4);
  static const patientPrimary = Color(0xFFCE9482);
  static const patientLightBg = Color(0xFFF2E5E1);
  static const sageGreen = Color(0xFFB0C29D);
  static const textDark = Color(0xFF3F4A3C);
  static const textMedium = Color(0xFF6B7566);
  static const appBackground = Color(0xFFF3EEDC);
  static const cardWhite = Color(0xFFFFFFFF);
  static const caregiverCard = Color(0xFFFFFFFF);

  // Static situation color constants (light values)
  static const situationTime = Color(0xFFE3F0EC);
  static const situationLocation = Color(0xFFE7EEDD);
  static const situationPerson = Color(0xFFF2E5E1);
  static const situationConfused = Color(0xFFE4ECF4);

  // Static card shadow — used by existing screens as `AppColors.cardShadow`
  static BoxShadow get cardShadow => BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );
}

extension AppColorsX on BuildContext {
  AppColors get appColors {
    if (AppSettings.highContrastMode) return AppColors.highContrast();
    return Theme.of(this).brightness == Brightness.dark
        ? AppColors.dark()
        : AppColors.light();
  }
}
