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
  final double? height;

  const PrimaryCtaButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.icon,
    this.isOutlined = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final resolvedColor = color ?? colors.primary;
    final resolvedTextColor = textColor ?? (isOutlined ? resolvedColor : Colors.white);

    final buttonChild = Row(
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
    );

    final ButtonStyle style = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: resolvedTextColor,
            backgroundColor: Colors.transparent,
            side: BorderSide(color: resolvedColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size(double.infinity, height ?? 65),
          )
        : FilledButton.styleFrom(
            backgroundColor: resolvedColor,
            foregroundColor: resolvedTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size(double.infinity, height ?? 65),
            elevation: 0,
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: onTap,
            style: style,
            child: buttonChild,
          )
        : FilledButton(
            onPressed: onTap,
            style: style,
            child: buttonChild,
          );

    // Only apply shadow for filled (not outlined) buttons
    return isOutlined
        ? button
        : Container(
            decoration: BoxDecoration(
              boxShadow: [colors.shadow],
              borderRadius: BorderRadius.circular(16),
            ),
            child: button,
          );
  }
}
