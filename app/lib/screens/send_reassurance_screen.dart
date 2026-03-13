// lib/screens/send_reassurance_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';
import '../widgets/animated_waveform.dart';

enum _RecordingState { idle, recording, saved }

class SendReassuranceScreen extends StatefulWidget {
  const SendReassuranceScreen({super.key});

  @override
  State<SendReassuranceScreen> createState() => _SendReassuranceScreenState();
}

class _SendReassuranceScreenState extends State<SendReassuranceScreen> {
  final _headlineController = TextEditingController();
  final _subtextController = TextEditingController();

  // Patient selector
  final Set<String> _selectedPatientIds = {AppState.defaultPatientId};

  // Voice recording
  bool _addVoice = false;
  _RecordingState _recordingState = _RecordingState.idle;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  bool _isPreviewPlaying = false;
  String? _recordingPath;

  final _recorder = AudioRecorder();
  final _previewPlayer = AudioPlayer();
  StreamSubscription? _previewCompletionSub;

  // Situation selector
  final Set<int> _selectedSituations = {};

  static const _situations = [
    'Unsure about time',
    'Unsure about location',
    'Unsure about someone',
    'In any situation',
  ];

  static const _situationColors = [
    AppColors.situationTime,
    AppColors.situationLocation,
    AppColors.situationPerson,
    AppColors.situationConfused,
  ];

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _snack('Microphone permission denied. Please allow it in Settings.');
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _recordingState = _RecordingState.recording;
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordingSeconds++);
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _recorder.stop();
    setState(() {
      _recordingState = _RecordingState.saved;
      _recordingPath = path;
    });
  }

  Future<void> _reRecord() async {
    await _previewPlayer.stop();
    setState(() {
      _recordingState = _RecordingState.idle;
      _recordingSeconds = 0;
      _isPreviewPlaying = false;
      _recordingPath = null;
    });
  }

  Future<void> _togglePreview() async {
    if (_isPreviewPlaying) {
      await _previewPlayer.stop();
      setState(() => _isPreviewPlaying = false);
      return;
    }
    if (_recordingPath == null) return;
    setState(() => _isPreviewPlaying = true);
    await _previewPlayer.play(DeviceFileSource(_recordingPath!));
    _previewCompletionSub?.cancel();
    _previewCompletionSub = _previewPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPreviewPlaying = false);
    });
  }

  void _save() {
    if (_selectedPatientIds.isEmpty) {
      _snack('Please select at least one patient.');
      return;
    }
    if (_selectedSituations.isEmpty) {
      _snack('Please select at least one situation.');
      return;
    }
    AppState.saveReassurance(
      patientIds: _selectedPatientIds.toList(),
      situationIndexes: _selectedSituations.toList(),
      headline: _headlineController.text,
      subtext: _subtextController.text,
      hasRecording: _recordingState == _RecordingState.saved,
      recordingDurationSeconds: _recordingSeconds,
      recordingPath: _recordingPath,
    );
    _snack('Reassurance saved!');
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _previewCompletionSub?.cancel();
    _recorder.dispose();
    _previewPlayer.dispose();
    _headlineController.dispose();
    _subtextController.dispose();
    super.dispose();
  }

  String get _timerLabel {
    final s = _recordingSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppColors.textMedium.withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFFF7F9FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E7EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E7EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.caregiverPrimary,
            width: 1.5,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [AppColors.cardShadow],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textDark,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Send Reassurance',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient selector
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Who is this for?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPatientChips(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Message section
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What would you like to say?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _headlineController,
                      maxLines: 2,
                      decoration: _inputDecoration('Main message...'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _subtextController,
                      decoration:
                          _inputDecoration('Secondary line (optional)...'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Voice recording section
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _addVoice = !_addVoice;
                        if (!_addVoice) {
                          _recordingTimer?.cancel();
                          _recorder.stop();
                          _previewPlayer.stop();
                          _recordingState = _RecordingState.idle;
                          _recordingSeconds = 0;
                          _isPreviewPlaying = false;
                          _recordingPath = null;
                        }
                      }),
                      child: Row(
                        children: [
                          _RadioDot(selected: _addVoice),
                          const SizedBox(width: 12),
                          const Text(
                            'Add a voice recording',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_addVoice) ...[
                      const SizedBox(height: 20),
                      _buildRecordingSection(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Situation selector
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'When should this be used?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Use this message when they are...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ..._situations.asMap().entries.map((e) {
                      final i = e.key;
                      final label = e.value;
                      final sel = _selectedSituations.contains(i);
                      final bgColor = _situationColors[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => sel
                              ? _selectedSituations.remove(i)
                              : _selectedSituations.add(i)),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? bgColor
                                  : bgColor.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? bgColor.withValues(alpha: 0.8)
                                    : bgColor.withValues(alpha: 0.3),
                                width: sel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sel
                                        ? AppColors.textDark
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: sel
                                          ? AppColors.textDark
                                          : AppColors.textMedium
                                              .withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: sel
                                      ? const Icon(Icons.check,
                                          size: 11, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textDark,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 60),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.caregiverPrimary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [AppColors.cardShadow],
                  ),
                  child: const Text(
                    'Save message',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientChips() {
    final patients = AppState.patients;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: patients.map((p) {
        final selected = _selectedPatientIds.contains(p.id);
        return GestureDetector(
          onTap: () => setState(() => selected
              ? _selectedPatientIds.remove(p.id)
              : _selectedPatientIds.add(p.id)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.caregiverPrimary
                  : const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.caregiverPrimary
                    : const Color(0xFFD8E2EC),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(Icons.check, color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                ],
                Text(
                  p.name,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecordingSection() {
    switch (_recordingState) {
      case _RecordingState.idle:
        return Column(
          children: [
            AnimatedWaveform(
                isActive: false,
                color: AppColors.textMedium.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _startRecording,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF0F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Start recording',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case _RecordingState.recording:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PulsingDot(),
                const SizedBox(width: 8),
                Text(
                  'Recording... $_timerLabel',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedWaveform(isActive: true, color: Colors.redAccent),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _stopRecording,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF0F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stop, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Stop',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case _RecordingState.saved:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.sageGreen, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Recording saved ($_timerLabel)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.sageGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedWaveform(isActive: _isPreviewPlaying),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _togglePreview,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.caregiverLightBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.caregiverPrimary
                              .withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPreviewPlaying ? Icons.stop : Icons.play_arrow,
                          color: AppColors.caregiverPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isPreviewPlaying ? 'Stop' : 'Preview',
                          style: const TextStyle(
                            color: AppColors.caregiverPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _reRecord,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF0F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic, color: Colors.redAccent, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Re-record',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? AppColors.caregiverPrimary
              : const Color(0xFFBEC8D2),
          width: 1.5,
        ),
        color: selected
            ? AppColors.caregiverPrimary.withValues(alpha: 0.1)
            : Colors.white,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.caregiverPrimary,
                ),
              ),
            )
          : null,
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);
  late final Animation<double> _opacity =
      Tween(begin: 0.3, end: 1.0).animate(_ctrl);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
          ),
        ),
      );
}
