// lib/widgets/dashboard_action_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DashboardActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const DashboardActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final iconCircleSize = isLarge ? 52.0 : 44.0;
    final iconSize = isLarge ? 26.0 : 22.0;
    final minHeight = isLarge ? 80.0 : 72.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [colors.shadow],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: isLarge ? 20 : 16,
        ),
        child: Row(
          children: [
            Container(
              width: iconCircleSize,
              height: iconCircleSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: iconSize),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isLarge ? 17 : 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textHigh,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textMed,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textLow,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
