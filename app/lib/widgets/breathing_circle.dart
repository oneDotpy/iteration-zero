// lib/widgets/breathing_circle.dart
import 'package:flutter/material.dart';

enum BreathPhase { inhale, hold, exhale }

class BreathingCircle extends StatelessWidget {
  final BreathPhase phase;
  final Color primaryColor;
  final bool reducedMotion;

  static const double _outerSize = 270.0;
  static const double _innerMin = 50.0;
  static const double _innerMax = 230.0;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.primaryColor,
    this.reducedMotion = false,
  });

  double get _targetInnerSize {
    if (reducedMotion) return (_innerMin + _innerMax) / 2;
    switch (phase) {
      case BreathPhase.inhale:
        return _innerMax;
      case BreathPhase.hold:
        return _innerMax;
      case BreathPhase.exhale:
        return _innerMin;
    }
  }

  Duration get _animDuration {
    if (reducedMotion) return Duration.zero;
    switch (phase) {
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
    return SizedBox(
      width: _outerSize,
      height: _outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring (fixed, faint)
          Container(
            width: _outerSize,
            height: _outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.20),
                width: 2,
              ),
            ),
          ),
          // Middle soft ring (slow pulse effect)
          AnimatedContainer(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(seconds: 3),
            curve: Curves.easeInOut,
            width: _outerSize - 24,
            height: _outerSize - 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.07),
            ),
          ),
          // Inner animated circle
          AnimatedContainer(
            duration: _animDuration,
            curve: Curves.easeInOut,
            width: _targetInnerSize,
            height: _targetInnerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
