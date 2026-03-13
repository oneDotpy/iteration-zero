import 'package:flutter/material.dart';
import 'breather_intro_screen.dart';

class BreathingDoneScreen extends StatelessWidget {
  final bool isCaregiver;
  const BreathingDoneScreen({super.key, required this.isCaregiver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Text(
                'Well done.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You did great.',
                style: TextStyle(fontSize: 22, color: Colors.black54),
              ),
              const Spacer(flex: 2),
              Center(
                child: SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BreatherIntroScreen(
                        isCaregiver: isCaregiver,
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFFE2EEFE),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Keep going',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: () => Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF9CC1FD),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
