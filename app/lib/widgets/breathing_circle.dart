// lib/widgets/breathing_circle.dart
import 'package:flutter/material.dart';

enum BreathPhase { inhale, hold, exhale }

class BreathingCircle extends StatefulWidget {
  final BreathPhase phase;
  final Color primaryColor;
  final bool reducedMotion;

  static const double outerSize = 270.0;
  static const double innerMin = 50.0;
  static const double innerMax = 230.0;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.primaryColor,
    this.reducedMotion = false,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle> {
  // Start false so the inner circle renders at innerMin on first frame,
  // then animates to the correct size after the first frame is drawn.
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  double get _targetInnerSize {
    if (!_ready) return BreathingCircle.innerMin;
    if (widget.reducedMotion) {
      return (BreathingCircle.innerMin + BreathingCircle.innerMax) / 2;
    }
    switch (widget.phase) {
      case BreathPhase.inhale:
        return BreathingCircle.innerMax;
      case BreathPhase.hold:
        return BreathingCircle.innerMax;
      case BreathPhase.exhale:
        return BreathingCircle.innerMin;
    }
  }

  Duration get _animDuration {
    if (widget.reducedMotion) return Duration.zero;
    switch (widget.phase) {
      case BreathPhase.inhale:
        return const Duration(seconds: 4);
      case BreathPhase.hold:
        return const Duration(milliseconds: 200);
      case BreathPhase.exhale:
        return const Duration(seconds: 6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor;
    const outer = BreathingCircle.outerSize;

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring (fixed, faint)
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.20),
                width: 2,
              ),
            ),
          ),
          // Middle soft ring
          AnimatedContainer(
            duration: widget.reducedMotion
                ? Duration.zero
                : const Duration(seconds: 3),
            curve: Curves.easeInOut,
            width: outer - 24,
            height: outer - 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.07),
            ),
          ),
          // Inner animated circle — starts small, expands on first frame
          AnimatedContainer(
            duration: _animDuration,
            curve: Curves.easeInOut,
            width: _targetInnerSize,
            height: _targetInnerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
