// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'setup_email_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              const Text(
                'Get started',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Connection, not correction.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(filled: true),
                  const SizedBox(width: 8),
                  _dot(filled: true),
                  const SizedBox(width: 8),
                  _dot(filled: true),
                ],
              ),
              const Spacer(flex: 2),
              _AppButton(
                label: 'Create an account',
                backgroundColor: const Color(0xFFFFF8D9),
                foregroundColor: Colors.black,
                onTap: () async {
                  try {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SetupEmailScreen(),
                      ),
                    );
                  } catch (_) {
                    // Optionally handle navigation errors.
                  }
                },
              ),
              const SizedBox(height: 12),
              _AppButton(
                label: 'Log in',
                backgroundColor: Color(0xFFFFDD8F),
                foregroundColor: Colors.black,
                onTap: () async {
                  try {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  } catch (_) {
                    // Optionally handle navigation errors.
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot({bool filled = false}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Color(0xFFFFDD8F) : Colors.black26,
      ),
    );
  }
}

class _AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  const _AppButton({
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // Set specific width instead of full width
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
