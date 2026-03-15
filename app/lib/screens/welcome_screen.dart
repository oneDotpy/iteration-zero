// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_cta_button.dart';
import 'login_screen.dart';
import 'create_account_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Center(
                child: Text(
                  'Get started',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    color: colors.textHigh,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Connection, not correction.',
                  style: TextStyle(fontSize: 16, color: colors.textMed),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(colors: colors, filled: true),
                  const SizedBox(width: 8),
                  _dot(colors: colors, filled: true),
                  const SizedBox(width: 8),
                  _dot(colors: colors, filled: true),
                ],
              ),
              const Spacer(flex: 2),
              PrimaryCtaButton(
                label: 'Create an account',
                color: colors.teal,
                isOutlined: true,
                onTap: () async {
                  try {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAccountScreen(),
                      ),
                    );
                  } catch (_) {
                    // Optionally handle navigation errors.
                  }
                },
              ),
              const SizedBox(height: 12),
              PrimaryCtaButton(
                label: 'Log in',
                color: colors.teal,
                textColor: colors.textHigh,
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

  Widget _dot({required AppColors colors, bool filled = false}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? colors.teal : colors.textLow,
      ),
    );
  }
}
