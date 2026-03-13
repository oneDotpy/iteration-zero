import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/animated_waveform.dart';
import 'guidance_topic_screen.dart';
import 'send_reassurance_screen.dart';
import 'breather_intro_screen.dart';
import 'manage_patients_screen.dart';
import 'welcome_screen.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

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
                'Hi, ${AppState.caregiverName}.',
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
              _HomeButton(
                label: 'Get some guidance',
                backgroundColor: const Color(0xFFCAF5B8),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GuidanceTopicScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _HomeButton(
                label: 'Send reassurance',
                backgroundColor: const Color(0xFFFFEAB4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SendReassuranceScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _HomeButton(
                label: 'Take a breather',
                backgroundColor: const Color(0xFFBFD7FE),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BreatherIntroScreen(isCaregiver: true),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _HomeButton(
                label: 'My patients',
                backgroundColor: const Color(0xFFFED7DB),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManagePatientsScreen(),
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

class _HomeButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _HomeButton({
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,
          foregroundColor: Colors.black,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
