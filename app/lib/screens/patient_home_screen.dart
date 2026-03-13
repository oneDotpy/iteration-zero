// lib/screens/patient_home_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_cta_button.dart';
import '../widgets/voice_input_bar.dart';
import 'patient_situation_screen.dart';
import 'patient_reassurance_screen.dart';
import 'breather_intro_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.roseLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top row: sign-out + settings
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SettingsScreen(isCaregiver: false),
                      ),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [colors.shadow],
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: colors.textMed,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Greeting
              Text(
                'Hello,',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                AppState.loggedInName.isNotEmpty ? AppState.loggedInName : AppState.patientName,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: colors.rose,
                  height: 1.05,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'How are you feeling?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: colors.textMed,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Avatar circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.rose.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.rose.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: [colors.shadow],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: colors.rose,
                  size: 52,
                ),
              ),

              const SizedBox(height: 36),

              // Buttons
              PrimaryCtaButton(
                label: 'I feel unsure',
                icon: Icons.help_outline_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientSituationScreen(),
                  ),
                ),
                color: colors.rose,
              ),

              const SizedBox(height: 14),

              PrimaryCtaButton(
                label: 'Hear a familiar voice',
                icon: Icons.volume_up_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientReassuranceScreen(
                      situationIndex: 3,
                    ),
                  ),
                ),
                color: colors.primary,
              ),

              const SizedBox(height: 14),

              PrimaryCtaButton(
                label: 'Take a breather',
                icon: Icons.air,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BreatherIntroScreen(
                      isCaregiver: false,
                    ),
                  ),
                ),
                color: colors.sage,
              ),

              const SizedBox(height: 20),

              // Voice input bar
              VoiceInputBar(color: colors.rose),

              const Spacer(),

              // Patient mode badge
              GestureDetector(
                onTap: () => _logout(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.rose.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: colors.rose,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Patient View',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.rose,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }
}
