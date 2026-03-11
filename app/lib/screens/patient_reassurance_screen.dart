import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/animated_waveform.dart';
import 'patient_home_screen.dart';

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
    Color(0xFFFFF3CD), // time - warm yellow
    Color(0xFFFFCDD2), // location - soft pink
    Color(0xFFEF5350), // someone - red
    Color(0xFF90CAF9), // confused - blue
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
    final isDark = idx == 2; // red background → white text

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                data.headline,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.subtext,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 48),

              // Play button
              Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.stop : Icons.play_arrow,
                      size: 40,
                    ),
                  ),
                ),
              ),

              if (_isPlaying) ...[
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Playing...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              AnimatedWaveform(isActive: _isPlaying),

              const Spacer(),
              Center(
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientHomeScreen(),
                      ),
                      (route) => false,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: doneColor,
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'DONE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
