import 'dart:math';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/animated_waveform.dart';
import 'patient_situation_screen.dart';
import 'patient_reassurance_screen.dart';
import 'breather_intro_screen.dart';
import 'welcome_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final Random _random = Random();
  int? _lastVoiceSituationIndex;

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _logout(context),
                    child: const Text(
                      'Sign out',
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Hi, ${AppState.patientName}.',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'How can we help?',
                style: TextStyle(fontSize: 24, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              _PatientButton(
                label: 'I feel unsure',
                backgroundColor: const Color(0xFFFED7DB),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientSituationScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _PatientButton(
                label: 'Hear a familiar voice',
                backgroundColor: const Color(0xFFFFEAB4),
                onTap: () {
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
              ),
              const SizedBox(height: 8),
              _PatientButton(
                label: 'Take a breather',
                backgroundColor: const Color(0xFFBFD7FE),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BreatherIntroScreen(
                      isCaregiver: false,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const AnimatedWaveform(),
              const SizedBox(height: 16),
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

class _PatientButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _PatientButton({
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 22),
          backgroundColor: backgroundColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
