// lib/screens/breathing_done_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_cta_button.dart';
import 'breather_intro_screen.dart';
import 'caregiver_home_screen.dart';
import 'patient_home_screen.dart';

class BreathingDoneScreen extends StatelessWidget {
  final bool isCaregiver;
  const BreathingDoneScreen({super.key, required this.isCaregiver});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primaryColor = isCaregiver ? colors.primary : colors.rose;
    final bgColor = isCaregiver ? colors.primaryLight : colors.roseLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Icon circle — sparkle or checkmark depending on reducedMotion
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppSettings.reducedMotion
                      ? Icons.check_circle_outline_rounded
                      : Icons.auto_awesome_rounded,
                  color: primaryColor,
                  size: 48,
                ),
              ),

              const SizedBox(height: 36),

              Text(
                'Well done.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                'You did great.',
                style: TextStyle(
                  fontSize: 24,
                  color: colors.textMed,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Keep going button
              PrimaryCtaButton(
                label: 'Keep going',
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BreatherIntroScreen(isCaregiver: isCaregiver),
                  ),
                ),
                color: primaryColor,
              ),

              const SizedBox(height: 12),

              // Finish button (outlined)
              PrimaryCtaButton(
                label: 'Finish',
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => isCaregiver
                        ? const CaregiverHomeScreen()
                        : const PatientHomeScreen(),
                  ),
                  (route) => false,
                ),
                isOutlined: true,
                color: primaryColor,
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
