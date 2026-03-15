// lib/screens/patient_situation_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/voice_input_bar.dart';
import '../widgets/primary_icon_button.dart';
import 'patient_reassurance_screen.dart';

class PatientSituationScreen extends StatelessWidget {
  const PatientSituationScreen({super.key});

  static const _situations = [
    _Situation(
      label: 'Unsure about time',
      icon: Icons.access_time_rounded,
      situationColorKey: 0,
      index: 0,
    ),
    _Situation(
      label: 'Unsure where I am',
      icon: Icons.location_on_outlined,
      situationColorKey: 1,
      index: 1,
    ),
    _Situation(
      label: 'Unsure about someone',
      icon: Icons.person_outline_rounded,
      situationColorKey: 2,
      index: 2,
    ),
    _Situation(
      label: 'I just feel confused',
      icon: Icons.help_outline_rounded,
      situationColorKey: 3,
      index: 3,
    ),
  ];

  Color _situationColor(AppColors colors, int key) {
    switch (key) {
      case 0:
        return colors.teal.withValues(alpha: 0.58);
      case 1:
        return colors.sage.withValues(alpha: 0.58);
      case 2:
        return colors.rose.withValues(alpha: 0.58)  ;
      default:
        return colors.primary.withValues(alpha: 0.58);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.roseLight,
      appBar: AppBar(
        backgroundColor: colors.roseLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: colors.rose,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 28),

              Text(
                'I feel...',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              ..._situations.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientReassuranceScreen(
                          situationIndex: s.index,
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: _situationColor(colors, s.situationColorKey),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [colors.shadow],
                      ),
                      child: Row(
                        children: [
                          Icon(s.icon, color: colors.textHigh, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              s.label,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colors.textHigh,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textMed,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Voice input bar
              VoiceInputBar(color: colors.rose),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Situation {
  final String label;
  final IconData icon;
  final int situationColorKey;
  final int index;

  const _Situation({
    required this.label,
    required this.icon,
    required this.situationColorKey,
    required this.index,
  });
}
