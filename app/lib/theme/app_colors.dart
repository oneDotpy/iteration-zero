// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color primary;
  final Color primaryLight;
  final Color rose;
  final Color roseLight;
  final Color sage;
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
        background: Color(0xFFF7F5F2),
        surface: Colors.white,
        surfaceAlt: Color(0xFFF0EDE8),
        primary: Color(0xFF7BA7BC),
        primaryLight: Color(0xFFE8F2F8),
        rose: Color(0xFFCB9A8E),
        roseLight: Color(0xFFFFF8F5),
        sage: Color(0xFF8BAF8E),
        textHigh: Color(0xFF2C2C2C),
        textMed: Color(0xFF6B7280),
        textLow: Color(0xFFADB5BD),
        border: Color(0xFFE8E2DC),
        situationTimeBg: Color(0xFFFFF3C8),
        situationLocationBg: Color(0xFFDCEEDC),
        situationPersonBg: Color(0xFFEBDBF0),
        situationConfusedBg: Color(0xFFD4E8F5),
      );

  static AppColors dark() => const AppColors(
        background: Color(0xFF16181C),
        surface: Color(0xFF22262E),
        surfaceAlt: Color(0xFF2A2F39),
        primary: Color(0xFF89B8D0),
        primaryLight: Color(0xFF1C2E3A),
        rose: Color(0xFFD4A89E),
        roseLight: Color(0xFF2D2018),
        sage: Color(0xFF9DC9A0),
        textHigh: Color(0xFFF0EDE8),
        textMed: Color(0xFFA0A8B0),
        textLow: Color(0xFF5A6070),
        border: Color(0xFF2E3340),
        situationTimeBg: Color(0xFF2E2A14),
        situationLocationBg: Color(0xFF1A2E1A),
        situationPersonBg: Color(0xFF261A2E),
        situationConfusedBg: Color(0xFF162230),
      );

  // ── Backwards-compat static constants (light values) ──────────────────────
  // Referenced by the protected screens that must not be modified.
  static const caregiverPrimary = Color(0xFF7BA7BC);
  static const caregiverLightBg = Color(0xFFE8F2F8);
  static const patientPrimary = Color(0xFFCB9A8E);
  static const patientLightBg = Color(0xFFFFF8F5);
  static const sageGreen = Color(0xFF8BAF8E);
  static const textDark = Color(0xFF2C2C2C);
  static const textMedium = Color(0xFF6B7280);
  static const appBackground = Color(0xFFF7F5F2);
  static const cardWhite = Color(0xFFFFFFFF);
  static const softPurple = Color(0xFF9B8EC4);
  static const caregiverCard = Color(0xFFFFFFFF);

  // Static situation color constants (light values)
  static const situationTime = Color(0xFFFFF3C8);
  static const situationLocation = Color(0xFFDCEEDC);
  static const situationPerson = Color(0xFFEBDBF0);
  static const situationConfused = Color(0xFFD4E8F5);

  // Static card shadow — used by existing screens as `AppColors.cardShadow`
  static BoxShadow get cardShadow => BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).brightness == Brightness.dark
      ? AppColors.dark()
      : AppColors.light();
}
