// lib/widgets/dashboard_action_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DashboardActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback onTap;
  final bool isLarge;

  final Widget? leading;
  final Widget? trailing;

  const DashboardActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.backgroundColor,
    required this.onTap,
    this.isLarge = false,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final iconCircleSize = isLarge ? 52.0 : 44.0;
    final iconSize = isLarge ? 26.0 : 22.0;
    final minHeight = isLarge ? 80.0 : 72.0;

    final Widget resolvedLeading = leading ??
        Container(
          width: iconCircleSize,
          height: iconCircleSize,
          decoration: BoxDecoration(
            color: (color ?? colors.teal).withAlpha(36),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon ?? Icons.circle,
            color: color ?? colors.teal,
            size: iconSize,
          ),
        );

    final Widget resolvedTrailing = trailing ??
        Icon(
          Icons.chevron_right_rounded,
          color: colors.textLow,
          size: 22,
        );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [colors.shadow],
        borderRadius: BorderRadius.circular(20),
      ),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? colors.surface,
          foregroundColor: colors.textHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: Size(double.infinity, minHeight),
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: isLarge ? 32 : 24,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return colors.textHigh.withOpacity(0.05);
            }
            return null;
          }),
        ),
        child: Row(
          children: [
            resolvedLeading,
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
            resolvedTrailing,
          ],
        ),
      ),
    );
  }
}
