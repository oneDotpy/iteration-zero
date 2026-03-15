// lib/screens/send_reassurance_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/animated_waveform.dart';
import '../widgets/primary_icon_button.dart';
import '../widgets/primary_cta_button.dart';
import 'send_reassurance_done_screen.dart';

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

  // Voice recording (simulated)
  bool _addVoice = false;
  _RecordingState _recordingState = _RecordingState.idle;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  bool _isPreviewPlaying = false;
  Timer? _previewTimer;

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

  void _startRecording() {
    setState(() {
      _recordingState = _RecordingState.recording;
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_recordingSeconds >= 10) {
        _stopRecording();
        return;
      }
      setState(() => _recordingSeconds++);
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() => _recordingState = _RecordingState.saved);
  }

  void _reRecord() {
    _previewTimer?.cancel();
    setState(() {
      _recordingState = _RecordingState.idle;
      _recordingSeconds = 0;
      _isPreviewPlaying = false;
    });
  }

  void _togglePreview() {
    if (_isPreviewPlaying) {
      _previewTimer?.cancel();
      setState(() => _isPreviewPlaying = false);
      return;
    }
    setState(() => _isPreviewPlaying = true);
    final duration = Duration(seconds: _recordingSeconds.clamp(1, 10));
    _previewTimer = Timer(duration, () {
      if (mounted) setState(() => _isPreviewPlaying = false);
    });
  }

  void _save() {
    if (_selectedPatientIds.isEmpty) {
      _snack('Please select at least one patient.');
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
    AppState.saveReassurance(
      patientIds: _selectedPatientIds.toList(),
      situationIndexes: _selectedSituations.toList(),
      headline: _headlineController.text,
      subtext: _subtextController.text,
      hasRecording: _recordingState == _RecordingState.saved,
      recordingDurationSeconds: _recordingSeconds,
    );
    _recordingTimer?.cancel();
    _previewTimer?.cancel();
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
    _previewTimer?.cancel();
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
                      onTap: () => setState(() {
                        _addVoice = !_addVoice;
                        if (!_addVoice) {
                          _recordingTimer?.cancel();
                          _previewTimer?.cancel();
                          _recordingState = _RecordingState.idle;
                          _recordingSeconds = 0;
                          _isPreviewPlaying = false;
                        }
                      }),
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
        return SizedBox(
          height: 130,
          child: Column(
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
          ),
        );

      case _RecordingState.recording:
        return SizedBox(
          height: 130,
          child: Column(
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
                      fontSize: 15,
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
          ),
        );

      case _RecordingState.saved:
        return SizedBox(
          height: 130,
          child: Column(
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
          ),
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
