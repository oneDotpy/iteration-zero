// lib/widgets/voice_input_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
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
    final colors = context.appColors;
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
        accentColor: colors.rose,
        timerLabel: _timerLabel,
        dotOpacity: _dotOpacity,
        onDone: _stopListening,
      );
    }

    return _TapToSpeakHoverButton(
      accentColor: accentColor,
      onTap: _startListening,
    );
  }


}

class _TapToSpeakHoverButton extends StatefulWidget {
  final Color accentColor;
  final VoidCallback onTap;
  const _TapToSpeakHoverButton({required this.accentColor, required this.onTap});

  @override
  State<_TapToSpeakHoverButton> createState() => _TapToSpeakHoverButtonState();
}

class _TapToSpeakHoverButtonState extends State<_TapToSpeakHoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = _hovering
        ? widget.accentColor.withValues(alpha: 0.18)
        : widget.accentColor.withValues(alpha: 0.10);
    final borderColor = _hovering
        ? widget.accentColor.withValues(alpha: 0.40)
        : widget.accentColor.withValues(alpha: 0.25);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic_none_rounded, color: widget.accentColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'Tap to speak',
                style: TextStyle(
                  fontSize: 15,
                  color: widget.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.rose.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.rose.withValues(alpha: 0.25),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.rose,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Listening... $timerLabel',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.rose,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _HoverDoneButton(onTap: onDone, colors: colors),
            
            ],
          ),
          const SizedBox(height: 6),
          AnimatedWaveform(isActive: true, color: colors.rose),
        ],
      ),
    );
  }
}

class _HoverDoneButton extends StatefulWidget {
  final VoidCallback onTap;
  final dynamic colors;
  const _HoverDoneButton({required this.onTap, required this.colors});

  @override
  State<_HoverDoneButton> createState() => _HoverDoneButtonState();
}

class _HoverDoneButtonState extends State<_HoverDoneButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = _hovering
        ? widget.colors.rose.withValues(alpha: 0.22)
        : widget.colors.rose.withValues(alpha: 0.12);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Done',
            style: TextStyle(
              fontSize: 13,
              color: widget.colors.rose,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
