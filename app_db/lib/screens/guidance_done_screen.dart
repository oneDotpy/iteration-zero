// lib/screens/guidance_done_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_cta_button.dart';
import 'guidance_topic_screen.dart';

class GuidanceDoneScreen extends StatelessWidget {
  const GuidanceDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.sageLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const Spacer(flex: 2),

              // Sage check circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colors.sage.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: colors.sage,
                  size: 56,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Happy to help.',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                "You're doing great.",
                style: TextStyle(
                  fontSize: 17,
                  color: colors.textMed,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Get more guidance
              PrimaryCtaButton(
                label: 'Get more guidance',
                onTap: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuidanceTopicScreen(),
                    ),
                  );
                },
                color: colors.sage,
              ),

              const SizedBox(height: 12),

              // Home button (outlined)
              PrimaryCtaButton(
                label: 'Home',
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                isOutlined: true,
                color: colors.sage,
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
