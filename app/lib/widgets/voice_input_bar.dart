import 'dart:async';
import 'package:flutter/material.dart';
import 'animated_waveform.dart';

enum _VoiceState { idle, listening, done }

class VoiceInputBar extends StatefulWidget {
  const VoiceInputBar({super.key});

  @override
  State<VoiceInputBar> createState() => _VoiceInputBarState();
}

class _VoiceInputBarState extends State<VoiceInputBar>
    with SingleTickerProviderStateMixin {
  _VoiceState _state = _VoiceState.idle;
  int _seconds = 0;
  Timer? _countdownTimer;
  Timer? _stopTimer;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  static const _maxSeconds = 10;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stopTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _state = _VoiceState.listening;
      _seconds = 0;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
      if (_seconds >= _maxSeconds) _stopListening();
    });

    _stopTimer = Timer(const Duration(seconds: _maxSeconds), _stopListening);
  }

  void _stopListening() {
    _countdownTimer?.cancel();
    _stopTimer?.cancel();
    if (!mounted) return;
    setState(() => _state = _VoiceState.done);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _state = _VoiceState.idle);
    });
  }

  String get _timerLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _state == _VoiceState.idle ? _startListening : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _state == _VoiceState.listening
              ? Colors.red.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case _VoiceState.idle:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedWaveform(),
            const SizedBox(height: 6),
            const Text(
              'Tap to speak',
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ],
        );

      case _VoiceState.listening:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _pulseAnim,
                  child: const Icon(Icons.mic, color: Colors.red, size: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  _timerLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _stopListening,
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const AnimatedWaveform(isActive: true, color: Colors.red),
          ],
        );

      case _VoiceState.done:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.black54, size: 22),
            SizedBox(height: 4),
            Text(
              'Got it!',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        );
    }
  }
}
