// lib/screens/caregiver_setup_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';
import '../widgets/primary_action_button.dart';
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
    _SituationOption('Confusion about time', AppColors.situationTime),
    _SituationOption('Confusion about location', AppColors.situationLocation),
    _SituationOption('Confusion about someone', AppColors.situationPerson),
    _SituationOption('Repetitive questioning', AppColors.situationConfused),
    _SituationOption('Agitation or frustration', const Color(0xFFFCE8E8)),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              _StepIndicator(currentStep: 0, totalSteps: 3),
              const SizedBox(height: 28),

              // Step 1: Who are you caring for?
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Who are you caring for?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_caringForOptions.length, (i) {
                      final selected = _caringFor == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _caringFor = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.caregiverLightBg
                                  : const Color(0xFFF7F9FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppColors.caregiverPrimary
                                    : const Color(0xFFE0E7EE),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                _RadioDot(selected: selected),
                                const SizedBox(width: 12),
                                Text(
                                  _caringForOptions[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textDark,
                                    fontWeight: selected
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

              const SizedBox(height: 20),

              // Step 2: Name
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What do they call you?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Your name...',
                        hintStyle: TextStyle(
                          color: AppColors.textMedium.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F9FB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
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
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Step 3: Situations
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Which situations happen most often?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_situationOptions.length, (i) {
                        final opt = _situationOptions[i];
                        final selected = _situation == i;
                        return GestureDetector(
                          onTap: () => setState(() => _situation = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? opt.color : opt.color.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? opt.color.withValues(alpha: 0.8)
                                    : opt.color.withValues(alpha: 0.3),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selected
                                        ? AppColors.textDark
                                        : AppColors.textMedium.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  opt.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: PrimaryActionButton(
            label: 'Next',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CaregiverSetupVoiceScreen(),
              ),
            ),
            color: AppColors.caregiverPrimary,
            textColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.caregiverPrimary
                    : AppColors.caregiverPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
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
        border: Border.all(
          color: selected ? AppColors.caregiverPrimary : const Color(0xFFBEC8D2),
          width: 1.5,
        ),
        color: selected ? AppColors.caregiverPrimary.withValues(alpha: 0.1) : Colors.white,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
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

class _SituationOption {
  final String label;
  final Color color;
  const _SituationOption(this.label, this.color);
}
