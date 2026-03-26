// lib/screens/breather_intro_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/primary_cta_button.dart';
import '../widgets/primary_icon_button.dart';
import 'breathing_screen.dart';


class BreatherIntroScreen extends StatelessWidget {
  final bool isCaregiver;
  final double? outerSize;
  final double? innerMinSize;
  final double? innerMaxSize;

  const BreatherIntroScreen({
    super.key,
    required this.isCaregiver,
    this.outerSize,
    this.innerMinSize,
    this.innerMaxSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bgColor = colors.primaryLight;
    final circleColor = colors.primary;
    final iconColor = colors.primaryLight;
    final buttonColor = colors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: colors.primaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: colors.primary,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          'Take a Breather',
          style: TextStyle(
            color: colors.textHigh,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // Breathing circle visual — shows gentle pulse in inhale phase
              Center(
                child: BreathingCircle(
                  phase: BreathPhase.inhale,
                  primaryColor: circleColor,
                  iconColor: iconColor,
                  reducedMotion: AppSettings.reducedMotion,
                  showCountdown: false,
                ),
              ),

              const SizedBox(height: 24),

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
