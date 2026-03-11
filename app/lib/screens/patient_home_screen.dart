import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/animated_waveform.dart';
import 'patient_situation_screen.dart';
import 'patient_reassurance_screen.dart';
import 'breather_intro_screen.dart';
import 'welcome_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
              const SizedBox(height: 40),
              _PatientButton(
                label: 'I feel unsure',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientSituationScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PatientButton(
                label: 'Hear a familiar voice',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientReassuranceScreen(
                      situationIndex: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PatientButton(
                label: 'Take a breather',
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
  final VoidCallback onTap;

  const _PatientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 22),
          side: const BorderSide(color: Colors.black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
