import 'package:flutter/material.dart';
import 'patient_reassurance_screen.dart';

class PatientSituationScreen extends StatelessWidget {
  const PatientSituationScreen({super.key});

  static const _situations = [
    _Situation('Unsure about time', Color(0xFFFFF3CD), 0),
    _Situation('Unsure where I am', Color(0xFFFFCDD2), 1),
    _Situation('Unsure about someone', Color(0xFFEF5350), 2),
    _Situation('I just feel confused', Color(0xFF90CAF9), 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              const Text(
                "What's happening right now?",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),
              ..._situations.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientReassuranceScreen(
                            situationIndex: s.index,
                          ),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: s.color,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        s.label,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const _WaveformWidget(),
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
            ],
          ),
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

class _Situation {
  final String label;
  final Color color;
  final int index;
  const _Situation(this.label, this.color, this.index);
}

class _WaveformWidget extends StatelessWidget {
  const _WaveformWidget();

  @override
  Widget build(BuildContext context) {
    final heights = [10.0, 18.0, 26.0, 14.0, 22.0, 12.0, 20.0, 8.0, 14.0, 20.0, 10.0, 6.0, 12.0, 5.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights.map((h) => Container(
        width: 3,
        height: h,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(2),
        ),
      )).toList(),
    );
  }
}
