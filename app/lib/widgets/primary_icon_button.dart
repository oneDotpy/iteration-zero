import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;
  final double size;
  final IconData icon;

  const AppBackButton({
    super.key,
    this.onTap,
    this.color,
    this.size = 32,
    this.icon = Icons.arrow_back_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final Color base = color ?? colors.textMed;
    final HSLColor hsl = HSLColor.fromColor(base);
    // Less contrast: adjust lightness by 10% instead of 30%
    final double hoverLightness = (hsl.lightness * 0.8).clamp(0.0, 1.0);
    final Color hoverColor = hsl.withLightness(hoverLightness).toColor();
    return _AnimatedIconButton(
      onTap: onTap,
      icon: icon,
      size: size,
      baseColor: base,
      hoverColor: hoverColor,
    );

  }
}

class _AnimatedIconButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final double size;
  final Color baseColor;
  final Color hoverColor;

  const _AnimatedIconButton({
    this.onTap,
    required this.icon,
    required this.size,
    required this.baseColor,
    required this.hoverColor,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool hovered) => setState(() => _hovered = hovered);
  void _setPressed(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    final color = (_hovered || _pressed) ? widget.hoverColor : widget.baseColor;
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          child: Icon(
            widget.icon,
            color: color,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}
