import 'package:flutter/material.dart';
import 'patient_reassurance_screen.dart';

class PatientSituationScreen extends StatelessWidget {
  const PatientSituationScreen({super.key});

  static const _lightPink = Color(0xFFFDEAEC);
  static const _darkPink = Color(0xFFFFC5CA);

  static const _situations = [
    _Situation('Unsure about time', _darkPink, 0),
    _Situation('Unsure where I am', _darkPink, 1),
    _Situation('Unsure about someone', _darkPink, 2),
    _Situation('I just feel confused', _darkPink, 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightPink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton.filled(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: _darkPink,
                  foregroundColor: Colors.black,
                ),
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
              const SizedBox(height: 16),
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
        color: filled ? _darkPink : Colors.black26,
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
