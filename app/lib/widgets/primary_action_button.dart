// lib/widgets/primary_action_button.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final String? subtitle;

  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.caregiverPrimary;
    final fgColor = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 72),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppColors.cardShadow],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: fgColor, size: 26),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: subtitle != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: fgColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: fgColor.withValues(alpha: 0.78),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            if (icon != null)
              Icon(Icons.chevron_right, color: fgColor.withValues(alpha: 0.6), size: 22),
          ],
        ),
      ),
    );
  }
}
