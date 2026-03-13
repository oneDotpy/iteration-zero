// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../main.dart';
import '../theme/app_colors.dart';
import '../widgets/settings_section_card.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool isCaregiver;

  const SettingsScreen({super.key, required this.isCaregiver});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool get _isDark => themeNotifier.value == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [colors.shadow],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colors.textHigh,
              size: 18,
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.textHigh,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              // ── A. Appearance ─────────────────────────────────────────────
              SettingsSectionCard(
                title: 'Appearance',
                children: [
                  // Dark mode toggle
                  _SettingsRow(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    trailing: Switch(
                      value: _isDark,
                      onChanged: (v) {
                        setState(() {
                          themeNotifier.value =
                              v ? ThemeMode.dark : ThemeMode.light;
                          AppSettings.themeMode = themeNotifier.value;
                        });
                      },
                      activeThumbColor: colors.primary,
                    ),
                  ),

                  // Text size
                  _SettingsRow(
                    icon: Icons.text_fields,
                    label: 'Text Size',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TextSizeButton(
                          label: 'A',
                          fontSize: 12,
                          isSelected: !AppSettings.largeTextMode,
                          color: colors.primary,
                          onTap: () => setState(
                              () => AppSettings.largeTextMode = false),
                        ),
                        const SizedBox(width: 6),
                        _TextSizeButton(
                          label: 'A',
                          fontSize: 15,
                          isSelected: AppSettings.largeTextMode,
                          color: colors.primary,
                          onTap: () =>
                              setState(() => AppSettings.largeTextMode = true),
                        ),
                        const SizedBox(width: 6),
                        _TextSizeButton(
                          label: 'A',
                          fontSize: 18,
                          isSelected: false,
                          color: colors.primary,
                          onTap: () =>
                              setState(() => AppSettings.largeTextMode = true),
                        ),
                      ],
                    ),
                  ),

                  // High contrast toggle
                  _SettingsRow(
                    icon: Icons.contrast,
                    label: 'High Contrast',
                    trailing: Switch(
                      value: AppSettings.highContrastMode,
                      onChanged: (v) =>
                          setState(() => AppSettings.highContrastMode = v),
                      activeThumbColor: colors.primary,
                    ),
                  ),

                  // Reduced motion toggle
                  _SettingsRow(
                    icon: Icons.animation,
                    label: 'Reduced Motion',
                    trailing: Switch(
                      value: AppSettings.reducedMotion,
                      onChanged: (v) =>
                          setState(() => AppSettings.reducedMotion = v),
                      activeThumbColor: colors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── B. Narration ──────────────────────────────────────────────
              SettingsSectionCard(
                title: 'Narration',
                children: [
                  _SettingsRow(
                    icon: Icons.record_voice_over_outlined,
                    label: 'Narration',
                    trailing: Switch(
                      value: AppSettings.narrationEnabled,
                      onChanged: (v) =>
                          setState(() => AppSettings.narrationEnabled = v),
                      activeThumbColor: colors.primary,
                    ),
                  ),
                  if (AppSettings.narrationEnabled) ...[
                    // Speed slider
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.speed,
                                  color: colors.textMed, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Speed',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colors.textHigh,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${AppSettings.narrationSpeed.toStringAsFixed(1)}x',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textMed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: AppSettings.narrationSpeed,
                            min: 0.5,
                            max: 2.0,
                            divisions: 6,
                            activeColor: colors.primary,
                            onChanged: (v) =>
                                setState(() => AppSettings.narrationSpeed = v),
                          ),
                        ],
                      ),
                    ),

                    // Volume slider
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.volume_up_outlined,
                                  color: colors.textMed, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Volume',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colors.textHigh,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(AppSettings.narrationVolume * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textMed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: AppSettings.narrationVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            activeColor: colors.primary,
                            onChanged: (v) => setState(
                                () => AppSettings.narrationVolume = v),
                          ),
                        ],
                      ),
                    ),

                    // Voice guidance toggle
                    _SettingsRow(
                      icon: Icons.mic_none_outlined,
                      label: 'Voice Guidance',
                      trailing: Switch(
                        value: AppSettings.voiceGuidanceEnabled,
                        onChanged: (v) => setState(
                            () => AppSettings.voiceGuidanceEnabled = v),
                        activeThumbColor: colors.primary,
                      ),
                    ),

                    // Explanation
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What gets narrated?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.textMed,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Breather flow instructions, guidance prompts, and patient reassurance messages can be read aloud. Voice guidance provides additional audio cues during the breathing exercise.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textLow,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // ── C. View Preferences ───────────────────────────────────────
              SettingsSectionCard(
                title:
                    '${widget.isCaregiver ? "Caregiver" : "Patient"} View Preferences',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Text(
                      widget.isCaregiver
                          ? 'You are using the Caregiver view. This gives you access to guidance tools, reassurance message management, breathing exercises, and patient profiles.'
                          : 'You are using the Patient view. This view is designed for the person receiving care — simple, warm, and focused on comfort.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textMed,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── D. Account ────────────────────────────────────────────────
              SettingsSectionCard(
                title: 'Account',
                children: [
                  _SettingsInfoRow(
                    icon: Icons.person_outline,
                    label: 'Name',
                    value: widget.isCaregiver
                        ? AppState.caregiverName
                        : AppState.patientName,
                  ),
                  _SettingsInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: widget.isCaregiver
                        ? AppState.caregiverEmail
                        : AppState.patientEmail,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Sign out',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helper widgets ────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: colors.textMed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.textHigh,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _SettingsInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingsInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: colors.textMed, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.textHigh,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: colors.textMed,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextSizeButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TextSizeButton({
    required this.label,
    required this.fontSize,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: color, width: 1.5)
              : Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: isSelected ? color : colors.textMed,
          ),
        ),
      ),
    );
  }
}
