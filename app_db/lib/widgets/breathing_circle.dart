// lib/widgets/breathing_circle.dart
import 'package:flutter/material.dart';

enum BreathPhase { inhale, hold, exhale }


class BreathingCircle extends StatefulWidget {
  final BreathPhase phase;
  final Color primaryColor;
  final Color? iconColor;
  final bool reducedMotion;
  final bool showCountdown;
  static const double outerSize = 270.0;
  static const double innerMin = 50.0;
  static const double innerMax = 270.0;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.primaryColor,
    this.iconColor,
    this.reducedMotion = false,
    this.showCountdown = true,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle> {
    int _countdown = 0;
    late Duration _countdownDuration;
    late int _countdownStart;
    @override
    void didUpdateWidget(covariant BreathingCircle oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.reducedMotion && (oldWidget.phase != widget.phase)) {
        _startCountdown();
      }
    }

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      if (widget.reducedMotion) {
        _startCountdown();
      }
    }

    void _startCountdown() {
      _countdownDuration = _countdownDurationForPhase(widget.phase);
      _countdownStart = _countdownDuration.inSeconds;
      setState(() => _countdown = _countdownStart);
      if (_countdownStart > 0) {
        Future.doWhile(() async {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted || !widget.reducedMotion) return false;
          if (_countdown <= 1) return false;
          setState(() => _countdown--);
          return _countdown > 1;
        });
      }
    }

    Duration _countdownDurationForPhase(BreathPhase phase) {
      switch (phase) {
        case BreathPhase.inhale:
          return const Duration(seconds: 4);
        case BreathPhase.hold:
          return const Duration(seconds: 4);
        case BreathPhase.exhale:
          return const Duration(seconds: 6);
      }
    }
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
      return BreathingCircle.innerMax;
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
        return const Duration(seconds: 4);
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
            width: outer,
            height: outer,
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
          // Countdown text — only shown in reduced motion mode, counts down from 4 or 6 based on phase
          if (widget.reducedMotion && widget.showCountdown) 
            Text(
              _countdown > 0 ? '$_countdown' : '',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          // Wind icon overlay — in reducedMotion, show instantly; otherwise, fade in as before
          if (widget.iconColor != null && _ready && widget.phase == BreathPhase.inhale && _targetInnerSize >= BreathingCircle.innerMax)
            widget.reducedMotion
                ? Icon(
                    Icons.air,
                    color: widget.iconColor ?? color,
                    size: 80,
                  )
                : FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 1400)),
                    builder: (context, snapshot) {
                      final show = snapshot.connectionState == ConnectionState.done;
                      return AnimatedOpacity(
                        opacity: show ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeIn,
                        child: Icon(
                          Icons.air,
                          color: widget.iconColor ?? color,
                          size: 80,
                        ),
                      );
                    },
                  ),
        ],
      ),
    );
  }
}
