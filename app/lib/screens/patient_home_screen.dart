// lib/screens/patient_home_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../widgets/primary_cta_button.dart';
import '../widgets/voice_input_bar.dart';
import '../widgets/primary_icon_button.dart';
import 'patient_situation_screen.dart';
import 'patient_reassurance_screen.dart';
import 'breather_intro_screen.dart';
import 'settings_screen.dart';
import '../services/widget_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final Random _random = Random();
  int? _lastVoiceSituationIndex;

  @override
  void initState() {
    super.initState();
    AppState.logPatientEvent(kEventAppOpen);
    WidgetService.updateCaregiverWidget();
  }

  static const _actionLabels = {
    kEventFeelUnsure: '"I feel unsure"',
    kEventHearVoice: '"Hear a familiar voice"',
    kEventBreather: '"Take a breather"',
  };

  void _logAndRefresh(String action) {
    AppState.logPatientEvent(action);
    _checkAndNotify(action);
    WidgetService.updateCaregiverWidget();
  }

  void _checkAndNotify(String action) {
    final stats = AppState.getUsageFor(AppState.defaultPatientId);
    final triggered = stats.checkThreshold(action);
    if (triggered == null || !mounted) return;
    final label = _actionLabels[triggered] ?? triggered;
    final count = stats.alertThresholds[triggered] ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppState.patientName} has used $label $count+ times today.',
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: const Color(0xFF6B8F71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  int _nextRandomVoiceSituationIndex() {
    const options = [0, 1, 2, 3];
    if (_lastVoiceSituationIndex == null) {
      final first = options[_random.nextInt(options.length)];
      _lastVoiceSituationIndex = first;
      return first;
    }

    final filtered = options.where((i) => i != _lastVoiceSituationIndex).toList();
    final next = filtered[_random.nextInt(filtered.length)];
    _lastVoiceSituationIndex = next;
    return next;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: settingsNotifier,
      builder: (context, _, __) {
        final colors = context.appColors;
        return Scaffold(
          backgroundColor: colors.background,
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
                      AppBackButton(
                        icon: Icons.settings_outlined,
                        color: colors.textLow,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(isCaregiver: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Greeting
                  Text(
                    'Hi, ${AppState.loggedInName.isNotEmpty ? AppState.loggedInName : AppState.patientName}',
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
                  const SizedBox(height: 24),
                  // Avatar circle
                  Container(
                    width: 100,
                    height: 100,
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
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  PrimaryCtaButton(
                    label: 'I feel unsure',
                    icon: Icons.help_outline_rounded,
                    onTap: () {
                      _logAndRefresh(kEventFeelUnsure);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PatientSituationScreen(),
                        ),
                      );
                    },
                    color: colors.rose,
                    key: const ValueKey('tall1'),
                    height: 72,
                  ),
                  if (AppState.hasVoiceRecordingFor(AppState.defaultPatientId)) ...[
                    const SizedBox(height: 10),
                    PrimaryCtaButton(
                      label: 'Hear a familiar voice',
                      icon: Icons.volume_up_outlined,
                      onTap: () {
                        AppState.logPatientEvent(kEventHearVoice);
                        _checkAndNotify(kEventHearVoice);
                        final randomIndex = _nextRandomVoiceSituationIndex();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientReassuranceScreen(
                              situationIndex: randomIndex,
                            ),
                          ),
                        );
                      },
                      color: colors.sage,
                      key: const ValueKey('tall2'),
                      height: 72,
                    ),
                  ],
                  const SizedBox(height: 10),
                  PrimaryCtaButton(
                    label: 'Take a breather',
                    icon: Icons.air,
                    onTap: () {
                      _logAndRefresh(kEventBreather);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BreatherIntroScreen(
                            isCaregiver: false,
                          ),
                        ),
                      );
                    },
                    color: colors.primary,
                    key: const ValueKey('tall3'),
                    height: 72,
                  ),
                  const SizedBox(height: 20),
                  // Voice input bar
                  VoiceInputBar(color: colors.rose),
                  const Spacer(),
                  // Patient mode badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
                          'Care Recipient View',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.rose,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
