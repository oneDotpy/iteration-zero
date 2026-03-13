import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/animated_waveform.dart';

class PatientReassuranceScreen extends StatefulWidget {
  final int situationIndex;
  const PatientReassuranceScreen({super.key, required this.situationIndex});

  @override
  State<PatientReassuranceScreen> createState() =>
      _PatientReassuranceScreenState();
}

class _PatientReassuranceScreenState extends State<PatientReassuranceScreen> {
  bool _isPlaying = false;
  Timer? _playTimer;

  static const _doneColors = [
    Color(0xFFFFDD8F), // dark yellow
    Color(0xFFFFC5CA), // dark pink
    Color(0xFFABEB96), // dark green
    Color(0xFF9CC1FD), // dark blue
  ];

  static const _backgroundColors = [
    Color(0xFFFFF8D9), // light yellow
    Color(0xFFFDEAEC), // light pink
    Color(0xFFE8FFD9), // light green
    Color(0xFFE2EEFE), // light blue
  ];

  void _togglePlay() {
    if (_isPlaying) {
      _playTimer?.cancel();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    _playTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.situationIndex.clamp(0, 3);
    final data = AppState.getMessagesFor(AppState.defaultPatientId)[idx]!;
    final doneColor = _doneColors[idx];
    final backgroundColor = _backgroundColors[idx];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton.filled(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: doneColor,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                data.headline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.subtext,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              const Spacer(),

              // Play button
              Center(
                child: Material(
                  color: doneColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _togglePlay,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(
                        _isPlaying ? Icons.stop : Icons.play_arrow,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              AnimatedWaveform(isActive: _isPlaying),

              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 200,
                  child: FilledButton(
                    onPressed: () => Navigator.popUntil(
                      context,
                      (route) => route.settings.name == 'patientHome' || route.isFirst,
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: doneColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
