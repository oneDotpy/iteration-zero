import 'dart:async';
import 'package:flutter/material.dart';
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
  static const _lightBlue = Color(0xFFE2EEFE);
  static const _darkBlue = Color(0xFF9CC1FD);

  _Phase _phase = _Phase.inhale;
  int _cyclesCompleted = 0;
  late AnimationController _controller;
  late Animation<double> _innerSizeAnim;
  Timer? _phaseTimer;

  // Outer ring is fixed; inner circle animates between these sizes
  static const _outerSize = 230.0;
  static const _innerMin = 42.0;
  static const _innerMax = _outerSize;
  static const _holdPulseOutset = 5.0;
  static const _pulseMaxSize = _innerMax + _holdPulseOutset;
  static const _pulseCanvasSize = _pulseMaxSize;

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
    _innerSizeAnim = Tween<double>(begin: _innerMin, end: _innerMax).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _startPhase(_Phase.inhale);
  }

  void _startPhase(_Phase phase) {
    setState(() => _phase = phase);
    final duration = _phaseDurations[phase]!;
    _controller.duration = duration;

    if (phase == _Phase.inhale) {
      _innerSizeAnim = Tween<double>(begin: _innerMin, end: _innerMax).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.forward(from: 0);
    } else if (phase == _Phase.hold) {
      final holdPeak = _innerMax + _holdPulseOutset;
      _innerSizeAnim = TweenSequence<double>([
        TweenSequenceItem(
          tween: ConstantTween<double>(_innerMax),
          weight: 0.6,
        ),
          TweenSequenceItem(
            tween: Tween<double>(begin: _innerMax, end: holdPeak)
                .chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: holdPeak, end: _innerMax)
                .chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 1,
          ),
      ]).animate(_controller);
      _controller.forward(from: 0);
    } else {
      _innerSizeAnim = Tween<double>(begin: _innerMax, end: _innerMin).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
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

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton.filled(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: _darkBlue,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Text(
                _phaseLabel,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(flex: 1),

              // Breathing circle: outer ring + animated inner filled circle
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final innerSize = _innerSizeAnim.value;
                  return SizedBox(
                    width: _pulseCanvasSize,
                    height: _pulseCanvasSize,
                    child: OverflowBox(
                      maxWidth: _pulseCanvasSize,
                      maxHeight: _pulseCanvasSize,
                      alignment: Alignment.center,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: _outerSize,
                            height: _outerSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _lightBlue,
                            ),
                          ),
                          Container(
                            width: innerSize,
                            height: innerSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _cyclesCompleted + 1
                          ? _darkBlue
                          : _lightBlue,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
