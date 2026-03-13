// lib/widgets/soft_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [colors.shadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
