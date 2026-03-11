import 'package:flutter/material.dart';
import 'caregiver_setup_voice_screen.dart';

class CaregiverSetupScreen extends StatefulWidget {
  const CaregiverSetupScreen({super.key});

  @override
  State<CaregiverSetupScreen> createState() => _CaregiverSetupScreenState();
}

class _CaregiverSetupScreenState extends State<CaregiverSetupScreen> {
  int? _caringFor;
  final TextEditingController _nameController = TextEditingController();
  // ignore: unused_field
  int? _situation;

  final List<String> _caringForOptions = [
    'Partner',
    'Parent',
    'Grandparent',
    'Someone else...',
  ];

  final List<_SituationOption> _situationOptions = [
    _SituationOption('Confusion about time', const Color(0xFFFFF3CD)),
    _SituationOption('Confusion about location', const Color(0xFFFFCDD2)),
    _SituationOption('Confusion about someone', const Color(0xFFEF5350)),
    _SituationOption('Repetitive questioning', const Color(0xFF90CAF9)),
    _SituationOption('Agitation or frustration', const Color(0xFF5C6BC0)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Caregiver Setup',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Who are you caring for?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(_caringForOptions.length, (i) {
                    final isLast = i == _caringForOptions.length - 1;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _caringFor = i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                _RadioDot(selected: _caringFor == i),
                                const SizedBox(width: 12),
                                Text(
                                  _caringForOptions[i],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: Colors.black26),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'What name do they call you?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Your name...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Which situation happens most often?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(_situationOptions.length, (i) {
                    final opt = _situationOptions[i];
                    final isLast = i == _situationOptions.length - 1;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _situation = i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: opt.color,
                                    border: Border.all(
                                      color: Colors.black26,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  opt.label,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: Colors.black26),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(filled: true),
                  const SizedBox(width: 8),
                  _dot(filled: true),
                  const SizedBox(width: 8),
                  _dot(),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CaregiverSetupVoiceScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                elevation: 0,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Next', style: TextStyle(fontSize: 16)),
            ),
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

class _SituationOption {
  final String label;
  final Color color;
  const _SituationOption(this.label, this.color);
}
