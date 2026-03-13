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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
        color: filled ? Colors.black : Colors.black26,
      ),
    );
  }
}

class _AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AppButton({required this.label, required this.onTap});

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
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
