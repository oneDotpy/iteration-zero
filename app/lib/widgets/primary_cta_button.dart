// lib/widgets/primary_cta_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;

  const PrimaryCtaButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final resolvedColor = color ?? colors.primary;
    final resolvedTextColor = textColor ?? (isOutlined ? resolvedColor : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : resolvedColor,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined
              ? Border.all(color: resolvedColor, width: 1.5)
              : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: resolvedColor.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: resolvedTextColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: resolvedTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
