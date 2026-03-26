import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';

class AnimatedWaveform extends StatefulWidget {
  final bool isActive;
  final Color color;

  const AnimatedWaveform({
    super.key,
    this.isActive = false,
    this.color = Colors.black,
  });

  @override
  State<AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<AnimatedWaveform> {
  int _frame = 0;
  Timer? _timer;

  static const _frames = [
    [12.0, 20.0, 30.0, 18.0, 26.0, 14.0, 22.0, 10.0, 16.0, 24.0, 12.0, 8.0, 14.0, 6.0],
    [18.0, 28.0, 16.0, 32.0, 12.0, 28.0, 20.0, 14.0, 26.0, 18.0, 22.0, 12.0, 8.0, 16.0],
    [8.0, 14.0, 26.0, 12.0, 30.0, 20.0, 16.0, 28.0, 10.0, 22.0, 18.0, 26.0, 14.0, 20.0],
    [22.0, 12.0, 24.0, 16.0, 10.0, 28.0, 14.0, 20.0, 30.0, 10.0, 18.0, 26.0, 12.0, 22.0],
  ];

  // Static (inactive) frame
  static const _staticFrame = [10.0, 18.0, 26.0, 14.0, 22.0, 12.0, 20.0, 8.0, 14.0, 20.0, 10.0, 6.0, 12.0, 5.0];

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _startAnimation();
  }

  @override
  void didUpdateWidget(AnimatedWaveform old) {
    super.didUpdateWidget(old);
    if (AppSettings.reducedMotion) {
      _stopAnimation();
      return;
    }
    if (widget.isActive && !old.isActive) {
      _startAnimation();
    } else if (!widget.isActive && old.isActive) {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    if (AppSettings.reducedMotion) return;
    _timer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      if (mounted) setState(() => _frame = (_frame + 1) % _frames.length);
    });
  }

  void _stopAnimation() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _frame = 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heights = widget.isActive ? _frames[_frame] : _staticFrame;
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: heights.asMap().entries.map((e) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 3,
            height: e.value,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }).toList(),
      ),
    );
  }
}
