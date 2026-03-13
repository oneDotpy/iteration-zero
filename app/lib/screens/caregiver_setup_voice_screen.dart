// lib/screens/caregiver_setup_voice_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_action_button.dart';
import 'caregiver_home_screen.dart';

class CaregiverSetupVoiceScreen extends StatefulWidget {
  const CaregiverSetupVoiceScreen({super.key});

  @override
  State<CaregiverSetupVoiceScreen> createState() =>
      _CaregiverSetupVoiceScreenState();
}

class _CaregiverSetupVoiceScreenState
    extends State<CaregiverSetupVoiceScreen> {
  int? _voiceChoice; // 0 = Yes, 1 = No

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator (step 3 of 3)
              _StepIndicator(currentStep: 2, totalSteps: 3),
              const Spacer(flex: 2),

              // Title section
              const Text(
                'Voice playback',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Would you like to record a familiar voice for reassurance messages?',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Yes card
              _VoiceChoiceCard(
                value: 0,
                label: 'Yes, set it up',
                subtitle: 'Record your voice to comfort them',
                icon: Icons.mic_outlined,
                selectedValue: _voiceChoice,
                onTap: () => setState(() => _voiceChoice = 0),
              ),

              const SizedBox(height: 14),

              // No card
              _VoiceChoiceCard(
                value: 1,
                label: 'Maybe later',
                subtitle: 'Use text messages for now',
                icon: Icons.schedule_outlined,
                selectedValue: _voiceChoice,
                onTap: () => setState(() => _voiceChoice = 1),
              ),

              const Spacer(flex: 3),

              // Finish setup button
              PrimaryActionButton(
                label: 'Finish setup',
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CaregiverHomeScreen(),
                  ),
                  (route) => false,
                ),
                color: AppColors.caregiverPrimary,
                textColor: Colors.white,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceChoiceCard extends StatelessWidget {
  final int value;
  final String label;
  final String subtitle;
  final IconData icon;
  final int? selectedValue;
  final VoidCallback onTap;

  const _VoiceChoiceCard({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedValue == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.caregiverLightBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.caregiverPrimary
                : const Color(0xFFE0E7EE),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [AppColors.cardShadow],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.caregiverPrimary.withValues(alpha: 0.15)
                    : const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? AppColors.caregiverPrimary
                    : AppColors.textMedium,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.caregiverPrimary : const Color(0xFFBEC8D2),
          width: 1.5,
        ),
        color: selected
            ? AppColors.caregiverPrimary.withValues(alpha: 0.1)
            : Colors.white,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.caregiverPrimary,
                ),
              ),
            )
          : null,
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.caregiverPrimary
                    : AppColors.caregiverPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
