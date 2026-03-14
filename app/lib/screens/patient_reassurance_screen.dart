// lib/screens/patient_reassurance_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_theme.dart';
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
  late final ReassuranceData _selectedMessage;

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

  void _togglePlay([ReassuranceData? data]) {
    if (_isPlaying) {
      _playTimer?.cancel();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    final dur = (data != null && data.recordingDurationSeconds > 0)
        ? Duration(seconds: data.recordingDurationSeconds)
        : const Duration(seconds: 4);
    _playTimer = Timer(dur, () {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void initState() {
    super.initState();
    final idx = widget.situationIndex.clamp(0, 3);
    _selectedMessage = AppState.getRandomMessageFor(
      patientId: AppState.defaultPatientId,
      situationIndex: idx,
    );
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.situationIndex.clamp(0, 3);
    final data = _selectedMessage;
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
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.subtext,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, color: AppColors.textMedium, height: 1.4),
              ),
              const Spacer(),

              // Play button
              Center(
                child: Material(
                  color: doneColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => _togglePlay(data),
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
