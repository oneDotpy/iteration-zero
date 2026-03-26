// lib/screens/send_reassurance_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/animated_waveform.dart';
import '../widgets/primary_icon_button.dart';
import '../widgets/primary_cta_button.dart';
import 'send_reassurance_done_screen.dart';
import '../services/widget_service.dart';
import '../services/firebase_service.dart';

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

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  // Media attachment
  String? _mediaPath;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  final ImagePicker _imagePicker = ImagePicker();

  // Situation selector
  final Set<int> _selectedSituations = {};

  bool _sent = false;
  String? _validationMessage;

  static const _situations = [
    'Unsure about time',
    'Unsure about location',
    'Unsure about someone',
    'In any situation',
  ];

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied.')),
        );
      }
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/reassurance_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );
    _recordingPath = path;
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
    await _recorder.stop();
    setState(() => _recordingState = _RecordingState.saved);
  }

  Future<void> _reRecord() async {
    await _player.stop();
    if (await _recorder.isRecording()) await _recorder.stop();
    if (_recordingPath != null) {
      final f = File(_recordingPath!);
      if (await f.exists()) await f.delete();
      _recordingPath = null;
    }
    setState(() {
      _recordingState = _RecordingState.idle;
      _recordingSeconds = 0;
      _isPreviewPlaying = false;
    });
  }

  Future<void> _togglePreview() async {
    if (_isPreviewPlaying) {
      await _player.stop();
      setState(() => _isPreviewPlaying = false);
      return;
    }
    if (_recordingPath == null) return;
    setState(() => _isPreviewPlaying = true);
    await _player.play(DeviceFileSource(_recordingPath!, mimeType: 'audio/mp4'));
    _player.onPlayerComplete.first.then((_) {
      if (mounted) setState(() => _isPreviewPlaying = false);
    });
  }

  Future<void> _save() async {
    if (_selectedPatientIds.isEmpty) {
      setState(() {
        _validationMessage = 'Please select at least one care recipient.';
      });
      return;
    }
    final missingSituation = _selectedSituations.isEmpty;
    final missingMessage = _headlineController.text.trim().isEmpty;
    if (missingSituation || missingMessage) {
      setState(() {
        if (missingSituation && missingMessage) {
          _validationMessage =
              'Please type a message and choose at least one situation.';
        } else if (missingSituation) {
          _validationMessage = 'Please choose at least one situation.';
        } else {
          _validationMessage = 'Please type a message.';
        }
      });
      return;
    }
    FirebaseService.saveReassurance(
      patientIds: _selectedPatientIds.toList(),
      situationIndexes: _selectedSituations.toList(),
      headline: _headlineController.text,
      subtext: _subtextController.text,
      hasRecording: _recordingState == _RecordingState.saved,
      recordingPath: _recordingPath,
      mediaPath: _mediaPath,
      isVideo: _isVideo,
    ).then((_) {
      WidgetService.updatePatientWidget();
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    });
    _recordingTimer?.cancel();
    _headlineController.clear();
    _subtextController.clear();
    final isCaregiver = AppState.loggedInRole == 'caregiver';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SendReassuranceDoneScreen(isCaregiver: isCaregiver),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _sent = false;
      _validationMessage = null;
    });
  }

  Future<void> _pickMedia(bool video) async {
    final file = video
        ? await _imagePicker.pickVideo(source: ImageSource.gallery)
        : await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null || !mounted) return;
    _videoController?.dispose();
    _videoController = null;
    if (video) {
      final ctrl = VideoPlayerController.file(File(file.path));
      await ctrl.initialize();
      setState(() {
        _mediaPath = file.path;
        _isVideo = true;
        _videoController = ctrl;
      });
    } else {
      setState(() {
        _mediaPath = file.path;
        _isVideo = false;
      });
    }
  }

  void _removeMedia() {
    _videoController?.dispose();
    setState(() {
      _mediaPath = null;
      _isVideo = false;
      _videoController = null;
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    _videoController?.dispose();
    _headlineController.dispose();
    _subtextController.dispose();
    super.dispose();
  }

  String get _timerLabel {
    final s = _recordingSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  InputDecoration _inputDecoration(String hint, AppColors colors) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.textMed.withValues(alpha: 0.5)),
        filled: true,
        fillColor: colors.surfaceAlt.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.rose,
            width: 1.5,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final situationColors = [
      colors.teal,
      colors.sage,
      colors.rose,
      colors.primary,
    ];
    final situationIconColors = [
      colors.teal,
      colors.sage,
      colors.rose,
      colors.primary,
    ];

    return Scaffold(
      backgroundColor: colors.roseLight,
      appBar: AppBar(
        backgroundColor: colors.roseLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: colors.rose,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          'Send Reassurance',
          style: TextStyle(
            color: colors.textHigh,
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
              SizedBox(
                width: double.infinity,
                child: SoftCard(
                  color: colors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Who is this for?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textHigh,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPatientChips(colors),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Message section
              SoftCard(
                color: colors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What would you like to say?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textHigh,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _headlineController,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textHigh,
                      ),
                      onChanged: (_) {
                        if (_validationMessage != null) {
                          setState(() => _validationMessage = null);
                        }
                      },
                      decoration: _inputDecoration('Main message...', colors),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _subtextController,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textHigh,
                      ),
                      decoration:
                          _inputDecoration('Secondary line (optional)...', colors),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Voice recording section
              SoftCard(
                color: colors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _addVoice = !_addVoice);
                        if (!_addVoice) {
                          _recordingTimer?.cancel();
                          _player.stop();
                          if (_recordingState == _RecordingState.recording) {
                            _recorder.stop();
                          }
                          setState(() {
                            _recordingState = _RecordingState.idle;
                            _recordingSeconds = 0;
                            _isPreviewPlaying = false;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          _RadioDot(selected: _addVoice, colors: colors),
                          const SizedBox(width: 12),
                          Text(
                            'Add a voice recording',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textHigh,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_addVoice) ...[
                      const SizedBox(height: 20),
                      _buildRecordingSection(colors),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Media attachment section
              SoftCard(
                color: colors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a photo or video',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textHigh),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Optional — shown to your care recipient alongside the message.',
                      style: TextStyle(fontSize: 13, color: colors.textMed),
                    ),
                    const SizedBox(height: 14),
                    if (_mediaPath == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _MediaPickButton(
                              icon: Icons.image_outlined,
                              label: 'Photo',
                              color: colors.teal,
                              onTap: () => _pickMedia(false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MediaPickButton(
                              icon: Icons.videocam_outlined,
                              label: 'Video',
                              color: colors.sage,
                              onTap: () => _pickMedia(true),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _isVideo && _videoController != null
                                ? AspectRatio(
                                    aspectRatio: _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  )
                                : Image.file(
                                    File(_mediaPath!),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeMedia,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          if (_isVideo)
                            const Center(
                              child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 48),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Situation selector
              SoftCard(
                color: colors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When should this be used?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textHigh,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Use this message when they are...',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textMed,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ..._situations.asMap().entries.map((e) {
                      final i = e.key;
                      final label = e.value;
                      final sel = _selectedSituations.contains(i);
                      final bgColor = situationColors[i];
                      final iconColor = situationIconColors[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            sel
                                ? _selectedSituations.remove(i)
                                : _selectedSituations.add(i);
                            _validationMessage = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? bgColor.withValues(alpha: 0.58)
                                  : bgColor.withValues(alpha: 0.24),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sel
                                        ? colors.textHigh
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: sel
                                          ? Colors.transparent
                                          : colors.textMed
                                              .withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: sel
                                      ? Icon(
                                          Icons.check,
                                          size: 11,
                                          color: iconColor,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.textHigh,
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

              if (!_sent && _validationMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.rose.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.rose.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colors.rose,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationMessage!,
                          style: TextStyle(
                            color: colors.rose,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Save button / confirmation
              if (_sent) ...[
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 60),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.sage,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [colors.shadow],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Reassurance sent!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _resetForm,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 52),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.rose.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colors.rose,
                              width: 1.4,
                            ),
                          ),
                          child: Text(
                            'Send more',
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.rose,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 52),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.rose,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [colors.shadow],
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ] else
                PrimaryCtaButton(
                  label: 'Send message',
                  onTap: _save,
                  color: colors.rose,
                  textColor: Colors.white,
                  height: 60,
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientChips(AppColors colors) {
    final patients = AppState.patients;
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: patients
          .map((p) => _buildPatientChip(colors: colors, patient: p))
          .toList(),
    );
  }

  Widget _buildPatientChip({
    required AppColors colors,
    required PatientProfile patient,
  }) {
    final selected = _selectedPatientIds.contains(patient.id);
    return GestureDetector(
      onTap: () => setState(() => selected
          ? _selectedPatientIds.remove(patient.id)
          : _selectedPatientIds.add(patient.id)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.rose : colors.roseLight,
          borderRadius: BorderRadius.circular(20),
          // No border for any state
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const SizedBox(
                width: 14,
                child: Icon(Icons.check, color: Colors.white, size: 14),
              ),
            if (selected) const SizedBox(width: 6),
            Text(
              patient.name,
              style: TextStyle(
                color: selected ? Colors.white : colors.textHigh,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection(AppColors colors) {
    switch (_recordingState) {
      case _RecordingState.idle:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedWaveform(
                isActive: false, color: colors.textMed.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _startRecording,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.rose.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.rose.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic, color: colors.rose, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Start recording',
                        style: TextStyle(
                          color: colors.rose,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PulsingDot(),
                const SizedBox(width: 6),
                Text(
                  'Recording... $_timerLabel',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.rose,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedWaveform(isActive: true, color: colors.rose),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _stopRecording,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.rose.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.rose.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stop, color: colors.rose, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Stop',
                        style: TextStyle(
                          color: colors.rose,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: colors.sage, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Recording saved ($_timerLabel)',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.sage,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Waveform animates when previewing
            AnimatedWaveform(isActive: _isPreviewPlaying, color: colors.rose),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _togglePreview,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: _isPreviewPlaying
                        ? BoxDecoration(
                            color: colors.rose.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.rose.withOpacity(0.4)),
                          )
                        : BoxDecoration(
                            color: colors.rose,
                            borderRadius: BorderRadius.circular(16),
                          ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPreviewPlaying ? Icons.stop : Icons.play_arrow,
                          color: _isPreviewPlaying ? colors.rose : Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isPreviewPlaying ? 'Stop' : 'Preview',
                          style: TextStyle(
                            color: _isPreviewPlaying ? colors.rose : Colors.white,
                            fontSize: 15,
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
                    constraints: const BoxConstraints(minWidth: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.rose.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.rose.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic, color: colors.rose, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Re-record',
                          style: TextStyle(
                            color: colors.rose,
                            fontSize: 15,
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
  final AppColors colors;
  const _RadioDot({required this.selected, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.rose : colors.textMed.withValues(alpha: 0.5),
          width: 1.5,
        ),
        color: selected
            ? colors.rose.withValues(alpha: 0.1)
            : colors.background,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.rose,
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appColors.rose,
          ),
        ),
      );
}

class _MediaPickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MediaPickButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
