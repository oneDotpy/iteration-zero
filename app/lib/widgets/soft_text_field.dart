// lib/widgets/soft_text_field.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SoftTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final String? label;
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final Color? fillColor;

  const SoftTextField({
    Key? key,
    this.controller,
    required this.hint,
    this.label,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textMed,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            color: colors.textHigh,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            errorStyle: TextStyle(color: colors.rose),
            hintStyle: TextStyle(color: colors.textLow),
            filled: true,
            fillColor: fillColor ?? colors.surfaceAlt,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: colors.textMed, size: 20)
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.teal, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.rose, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.rose, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
