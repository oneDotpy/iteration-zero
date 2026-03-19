// lib/screens/patient_reassurance_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_waveform.dart';
import '../widgets/primary_cta_button.dart';
import '../widgets/primary_icon_button.dart';

class PatientReassuranceScreen extends StatefulWidget {
  final int situationIndex;
  const PatientReassuranceScreen({super.key, required this.situationIndex});

  @override
  State<PatientReassuranceScreen> createState() =>
      _PatientReassuranceScreenState();
}

class _PatientReassuranceScreenState extends State<PatientReassuranceScreen> {
  bool _isPlaying = false;
  late final ReassuranceData _selectedMessage;
  final AudioPlayer _player = AudioPlayer();
  VideoPlayerController? _videoController;

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
      return;
    }
    final path = _selectedMessage.recordingPath;
    if (path == null) return;
    setState(() => _isPlaying = true);
    await _player.play(DeviceFileSource(path));
    _player.onPlayerComplete.first.then((_) {
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
    _initVideo();
  }

  Future<void> _initVideo() async {
    final path = _selectedMessage.mediaPath;
    if (path == null || !_selectedMessage.isVideo) return;
    final ctrl = VideoPlayerController.file(File(path));
    await ctrl.initialize();
    if (mounted) {
      setState(() => _videoController = ctrl);
      ctrl.setLooping(true);
      ctrl.play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.situationIndex.clamp(0, 3);
    final data = _selectedMessage;
    final colors = context.appColors;
    // Situation color mapping: 0=time, 1=location, 2=someone, 3=other
    final List<Color> situationColors = [
      colors.teal,      // time
      colors.sage,      // location
      colors.rose,      // someone
      colors.primary,   // other
    ];
    final situationColor = situationColors[idx];
    // Situation background color mapping: 0=time, 1=location, 2=someone, 3=other
    final List<Color> situationBgColors = [
      colors.tealLight,      // time
      colors.sageLight,  // location
      colors.roseLight,    // someone
      colors.primaryLight,  // other
    ];
    final situationBgColor = situationBgColors[idx];

    return Scaffold(
      backgroundColor: situationBgColor,
      appBar: AppBar(
        backgroundColor: situationBgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: situationColor,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                data.headline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.subtext,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24, color: colors.textMed, height: 1.4),
              ),
              // Media (photo or video)
              if (data.mediaPath != null) ...[
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: data.isVideo && _videoController != null
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : Image.file(
                          File(data.mediaPath!),
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                ),
              ],

              const Spacer(),

              if (data.recordingPath != null) ...[
                // Play button
                Center(
                  child: Material(
                    color: situationColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _togglePlay,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Icon(
                          _isPlaying ? Icons.stop : Icons.play_arrow,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                AnimatedWaveform(isActive: _isPlaying, color: colors.textHigh),

                const SizedBox(height: 48),
              ],
              Center(
                child: SizedBox(
                  width: 200,
                  child: PrimaryCtaButton(
                    label: 'Done',
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        Navigator.popUntil(
                          context,
                          (route) => route.settings.name == 'patientHome' || route.isFirst,
                        );
                      });
                    },
                    color: situationColor,
                    textColor: Colors.white,
                    height: 56,
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
