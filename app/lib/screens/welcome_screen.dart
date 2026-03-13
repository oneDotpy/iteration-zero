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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF16181C),
                    const Color(0xFF1C2330),
                  ]
                : [
                    const Color(0xFFF7F5F2),
                    const Color(0xFFE8F0F5),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Hero abstract illustration — 3 overlapping soft circles
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Back circle — rose
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.rose.withValues(alpha: 0.30),
                            ),
                          ),
                        ),
                        // Mid circle — sage
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.sage.withValues(alpha: 0.28),
                            ),
                          ),
                        ),
                        // Front circle — primary blue
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withValues(alpha: 0.40),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: colors.primary,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Wordmark
                  Text(
                    '[un]scripted',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: colors.textHigh,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    'Connection, not correction.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: colors.textMed,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 56),

                  // Create Account button
                  PrimaryCtaButton(
                    label: 'Create Account',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAccountScreen(),
                      ),
                    ),
                    color: colors.primary,
                  ),

                  const SizedBox(height: 14),

                  // Log In button (outlined)
                  PrimaryCtaButton(
                    label: 'Log In',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    ),
                    isOutlined: true,
                    color: colors.primary,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
