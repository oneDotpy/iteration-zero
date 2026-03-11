import 'package:flutter/material.dart';
import 'caregiver_home_screen.dart';

class CaregiverSetupVoiceScreen extends StatefulWidget {
  const CaregiverSetupVoiceScreen({super.key});

  @override
  State<CaregiverSetupVoiceScreen> createState() =>
      _CaregiverSetupVoiceScreenState();
}

class _CaregiverSetupVoiceScreenState
    extends State<CaregiverSetupVoiceScreen> {
  int? _voiceChoice; // 0 = Yes, 1 = No

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Text(
                'Caregiver Setup',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Spacer(flex: 3),
              const Text(
                'Would you like to use voice playback?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _choiceRow(0, 'Yes'),
                    const Divider(height: 1, color: Colors.black26),
                    _choiceRow(1, 'No'),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(filled: true),
                  const SizedBox(width: 8),
                  _dot(filled: true),
                  const SizedBox(width: 8),
                  _dot(filled: true),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverHomeScreen(),
                    ),
                    (route) => false,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Finish setup',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceRow(int value, String label) {
    return InkWell(
      onTap: () => setState(() => _voiceChoice = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _RadioDot(selected: _voiceChoice == value),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _dot({bool filled = false}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.black : Colors.black26,
      ),
    );
  }
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
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
            )
          : null,
    );
  }
}
