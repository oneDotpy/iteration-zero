// lib/screens/patient_reassurance_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../app_state.dart';
import '../theme/app_theme.dart';
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
  final _player = AudioPlayer();
  StreamSubscription? _completionSub;

  static const _situationBgColors = [
    AppColors.situationTime,
    AppColors.situationLocation,
    AppColors.situationPerson,
    AppColors.situationConfused,
  ];

  static const _situationAccentColors = [
    Color(0xFFD4A017),
    Color(0xFF5A9A5E),
    Color(0xFF8B5CAB),
    AppColors.caregiverPrimary,
  ];

  @override
  void initState() {
    super.initState();
    _completionSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _togglePlay(ReassuranceData data) async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
      return;
    }
    if (data.recordingPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No voice message recorded yet.'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isPlaying = true);
    await _player.play(DeviceFileSource(data.recordingPath!));
  }

  @override
  void dispose() {
    _completionSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.situationIndex.clamp(0, 3);
    final data = AppState.getMessagesFor(AppState.defaultPatientId)[idx]!;
    final bgColor = _situationBgColors[idx];
    final accentColor = _situationAccentColors[idx];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textDark, size: 20),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Text(
                data.headline,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                data.subtext,
                style: const TextStyle(
                    fontSize: 20, color: AppColors.textMedium, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (data.hasRecording && data.recordingPath != null) ...[
                GestureDetector(
                  onTap: () => _togglePlay(data),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      size: 42,
                      color: accentColor,
                    ),
                  ),
                ),
                if (_isPlaying) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Playing...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                AnimatedWaveform(isActive: _isPlaying, color: accentColor),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_off_outlined,
                          size: 18, color: AppColors.textMedium),
                      SizedBox(width: 8),
                      Text('No voice message yet',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textMedium)),
                    ],
                  ),
                ),
              ],
              const Spacer(flex: 2),
              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PatientHomeScreen()),
                  (route) => false,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 64),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [AppColors.cardShadow],
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
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
