import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_cta_button.dart';
import 'send_reassurance_screen.dart';

class SendReassuranceDoneScreen extends StatelessWidget {
  final bool isCaregiver;
  const SendReassuranceDoneScreen({super.key, required this.isCaregiver});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final rose = colors.rose;
    final bgColor = colors.roseLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Icon circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: rose.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: rose,
                  size: 56,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Message sent!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                'Your reassurance is on its way.',
                style: TextStyle(
                  fontSize: 17,
                  color: colors.textMed,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Send another button
              PrimaryCtaButton(
                label: 'Send another',
                onTap: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SendReassuranceScreen(),
                    ),
                  );
                },
                color: rose,
              ),

              const SizedBox(height: 12),

              // Home button (outlined)
              PrimaryCtaButton(
                label: 'Home',
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                isOutlined: true,
                color: rose,
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
