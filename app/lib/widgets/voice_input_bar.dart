// lib/widgets/voice_input_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import 'animated_waveform.dart';

/// Tappable bar that simulates voice input. Tap to start listening,
/// tap Done (or wait 10 s) to stop.
class VoiceInputBar extends StatefulWidget {
  final Color? color;
  const VoiceInputBar({super.key, this.color});

  @override
  State<VoiceInputBar> createState() => _VoiceInputBarState();
}

enum _VoiceState { idle, listening, done }

class _VoiceInputBarState extends State<VoiceInputBar>
    with SingleTickerProviderStateMixin {
  _VoiceState _state = _VoiceState.idle;
  int _seconds = 0;
  Timer? _timer;

  late final AnimationController _dotCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _dotOpacity =
      Tween(begin: 0.3, end: 1.0).animate(_dotCtrl);

  void _startListening() {
    setState(() {
      _state = _VoiceState.listening;
      _seconds = 0;
    });
    if (!AppSettings.reducedMotion) _dotCtrl.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds >= 10) {
        _stopListening();
        return;
      }
      setState(() => _seconds++);
    });
  }

  void _stopListening() {
    _timer?.cancel();
    _dotCtrl.stop();
    _dotCtrl.reset();
    setState(() {
      _state = _VoiceState.done;
      _seconds = 0;
    });
    // Return to idle after showing "Got it" for 1.5 s
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _state = _VoiceState.idle);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dotCtrl.dispose();
    super.dispose();
  }

  String get _timerLabel =>
      '0:${_seconds.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.color ?? const Color(0xFF7BA7BC);

    if (_state == _VoiceState.done) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF8BAF8E).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF8BAF8E).withValues(alpha: 0.35),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF8BAF8E), size: 20),
            SizedBox(width: 8),
            Text(
              'Got it!',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF8BAF8E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_state == _VoiceState.listening) {
      return _ListeningBar(
        accentColor: accentColor,
        timerLabel: _timerLabel,
        dotOpacity: _dotOpacity,
        onDone: _stopListening,
      );
    }

    return GestureDetector(
      onTap: _startListening,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_none_rounded, color: accentColor, size: 22),
            const SizedBox(width: 8),
            Text(
              'Tap to speak',
              style: TextStyle(
                fontSize: 15,
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningBar extends StatelessWidget {
  final Color accentColor;
  final String timerLabel;
  final Animation<double> dotOpacity;
  final VoidCallback onDone;

  const _ListeningBar({
    required this.accentColor,
    required this.timerLabel,
    required this.dotOpacity,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              FadeTransition(
                opacity: dotOpacity,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Listening... $timerLabel',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDone,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedWaveform(isActive: true, color: Colors.redAccent),
        ],
      ),
    );
  }
}
