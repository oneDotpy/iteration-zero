// lib/screens/breathing_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/primary_icon_button.dart';
import 'breathing_done_screen.dart';

enum _Phase { inhale, hold, exhale }

class BreathingScreen extends StatefulWidget {
  final bool isCaregiver;
  const BreathingScreen({super.key, required this.isCaregiver});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {

  _Phase _phase = _Phase.inhale;
  int _cyclesCompleted = 0;
  late AnimationController _controller;
  Timer? _phaseTimer;

  static const _phaseDurations = {
    _Phase.inhale: Duration(seconds: 4),
    _Phase.hold: Duration(seconds: 4),
    _Phase.exhale: Duration(seconds: 6),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _phaseDurations[_Phase.inhale],
    );
    _startPhase(_Phase.inhale);
  }

  void _startPhase(_Phase phase) {
    setState(() => _phase = phase);
    final duration = _phaseDurations[phase]!;
    _controller.duration = duration;

    if (phase == _Phase.inhale) {
      _controller.duration = _phaseDurations[phase];
      _controller.forward(from: 0);
    } else if (phase == _Phase.hold) {
      // Circle stays at max — BreathingCircle widget handles visual hold
    } else {
      _controller.duration = _phaseDurations[phase];
      _controller.forward(from: 0);
    }

    _phaseTimer?.cancel();
    _phaseTimer = Timer(duration, _nextPhase);
  }

  void _nextPhase() {
    if (!mounted) return;
    switch (_phase) {
      case _Phase.inhale:
        _startPhase(_Phase.hold);
      case _Phase.hold:
        _startPhase(_Phase.exhale);
      case _Phase.exhale:
        final next = _cyclesCompleted + 1;
        if (next >= 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BreathingDoneScreen(isCaregiver: widget.isCaregiver),
            ),
          );
        } else {
          setState(() => _cyclesCompleted = next);
          _startPhase(_Phase.inhale);
        }
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case _Phase.inhale:
        return 'Inhale';
      case _Phase.hold:
        return 'Hold';
      case _Phase.exhale:
        return 'Exhale';
    }
  }

  String get _phaseHint {
    switch (_phase) {
      case _Phase.inhale:
        return 'Slowly...';
      case _Phase.hold:
        return 'You got this!';
      case _Phase.exhale:
        return 'You\'re doing great!';
    }
  }

  BreathPhase get _breathPhase {
    switch (_phase) {
      case _Phase.inhale:
        return BreathPhase.inhale;
      case _Phase.hold:
        return BreathPhase.hold;
      case _Phase.exhale:
        return BreathPhase.exhale;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primaryColor = colors.primary;
    final bgColor = colors.primaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: colors.primary,
          onTap: () => Navigator.pop(context),
        ),
        title: null,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // Phase label
            Text(
              _phaseLabel,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 0),

            // Phase hint text
            Text(
              _phaseHint,
              style: TextStyle(
                fontSize: 15,
                color: colors.textMed.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 60),

            // Breathing circle — uses BreathingCircle widget driven by phase, no wind icon
            BreathingCircle(
              phase: _breathPhase,
              primaryColor: primaryColor,
              reducedMotion: AppSettings.reducedMotion,
            ),

            const Spacer(flex: 2),

            // Cycle dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i < _cyclesCompleted + 1 ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i < _cyclesCompleted + 1
                        ? primaryColor
                        : primaryColor.withValues(alpha: 0.2),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
