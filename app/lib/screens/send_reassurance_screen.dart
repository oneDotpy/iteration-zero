import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
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
  Timer? _previewTimer;

  // Situation selector
  final Set<int> _selectedSituations = {};

  static const _situations = [
    'Unsure about time',
    'Unsure about location',
    'Unsure about someone',
    'In any situation',
  ];

  // ── Recording ────────────────────────────────────────────────────────────

  void _startRecording() {
    setState(() {
      _recordingState = _RecordingState.recording;
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordingSeconds++);
      if (_recordingSeconds >= 10) _stopRecording();
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
    _previewTimer = Timer(
      Duration(seconds: _recordingSeconds.clamp(1, 10)),
      () { if (mounted) setState(() => _isPreviewPlaying = false); },
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

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
    );
    _snack('Reassurance saved!');
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Send Reassurance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Patient selector ─────────────────────────────────────────
              const Text(
                'Who is this for?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildPatientChips(),

              // ── Message ──────────────────────────────────────────────────
              const SizedBox(height: 24),
              const Text(
                'What would you like to say?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _headlineController,
                maxLines: 2,
                decoration: _inputDecoration('Main message...'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _subtextController,
                decoration: _inputDecoration('Secondary line (optional)...'),
              ),

              // ── Voice recording ──────────────────────────────────────────
              const SizedBox(height: 20),
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
                    _RadioDot(selected: _addVoice),
                    const SizedBox(width: 12),
                    const Text('Add a voice recording',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              if (_addVoice) ...[
                const SizedBox(height: 16),
                _buildRecordingSection(),
              ],

              // ── Situation selector ───────────────────────────────────────
              const SizedBox(height: 28),
              const Text(
                'When should this be used?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Use this message when they are...',
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
              const SizedBox(height: 12),
              ..._situations.asMap().entries.map((e) {
                final i = e.key;
                final label = e.value;
                final sel = _selectedSituations.contains(i);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => setState(() =>
                          sel ? _selectedSituations.remove(i) : _selectedSituations.add(i)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: sel ? Colors.black : Colors.grey[200],
                        foregroundColor: sel ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(label, style: const TextStyle(fontSize: 15)),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('DONE',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
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
        return FilterChip(
          label: Text(p.name),
          selected: selected,
          onSelected: (val) => setState(() =>
              val ? _selectedPatientIds.add(p.id) : _selectedPatientIds.remove(p.id)),
          selectedColor: Colors.black,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          backgroundColor: Colors.grey[200],
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }).toList(),
    );
  }

  Widget _buildRecordingSection() {
    switch (_recordingState) {
      case _RecordingState.idle:
        return Column(children: [
          AnimatedWaveform(isActive: false, color: Colors.black38),
          const SizedBox(height: 12),
          SizedBox(
            width: 180,
            child: OutlinedButton.icon(
              onPressed: _startRecording,
              icon: const Icon(Icons.mic, color: Colors.red),
              label: const Text('Start recording'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ]);

      case _RecordingState.recording:
        return Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingDot(),
              const SizedBox(width: 8),
              Text(
                'Recording... $_timerLabel',
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.red,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedWaveform(isActive: true, color: Colors.red),
          const SizedBox(height: 12),
          SizedBox(
            width: 140,
            child: OutlinedButton.icon(
              onPressed: _stopRecording,
              icon: const Icon(Icons.stop, color: Colors.red),
              label: const Text('Stop'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ]);

      case _RecordingState.saved:
        return Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 6),
              Text(
                'Recording saved ($_timerLabel)',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedWaveform(isActive: _isPreviewPlaying),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _togglePreview,
                icon: Icon(
                    _isPreviewPlaying ? Icons.stop : Icons.play_arrow,
                    size: 18),
                label: Text(_isPreviewPlaying ? 'Stop' : 'Preview'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _reRecord,
                icon: const Icon(Icons.mic, size: 18),
                label: const Text('Re-record'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ]);
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      );
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black54, width: 1.5),
        color: Colors.grey[200],
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black),
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
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
        ..repeat(reverse: true);
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
              shape: BoxShape.circle, color: Colors.red),
        ),
      );
}
