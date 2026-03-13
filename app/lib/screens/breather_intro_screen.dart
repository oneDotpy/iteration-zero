// lib/screens/breather_intro_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/primary_cta_button.dart';
import 'breathing_screen.dart';

class BreatherIntroScreen extends StatelessWidget {
  final bool isCaregiver;
  const BreatherIntroScreen({super.key, required this.isCaregiver});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bgColor = isCaregiver ? colors.primaryLight : colors.roseLight;
    final circleColor = isCaregiver ? colors.primary : colors.rose;
    final buttonColor = isCaregiver ? colors.primary : colors.rose;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [colors.shadow],
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: colors.textHigh,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Breathing circle visual — shows gentle pulse in inhale phase
              Center(
                child: BreathingCircle(
                  phase: BreathPhase.inhale,
                  primaryColor: circleColor,
                  reducedMotion: AppSettings.reducedMotion,
                ),
              ),

              const Spacer(flex: 1),

              Text(
                "Let's take\nsome deep\nbreaths.",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'A calm moment, just for you.',
                style: TextStyle(
                  fontSize: 17,
                  color: colors.textMed,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Begin button
              PrimaryCtaButton(
                label: 'Begin',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BreathingScreen(isCaregiver: isCaregiver),
                  ),
                ),
                color: buttonColor,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
