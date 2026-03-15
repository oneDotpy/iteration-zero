// lib/screens/caregiver_home_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/primary_icon_button.dart';
import '../widgets/voice_input_bar.dart';
import 'guidance_topic_screen.dart';
import 'send_reassurance_screen.dart';
import 'breather_intro_screen.dart';
import 'manage_patients_screen.dart';
import 'settings_screen.dart';
import '../main.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: settingsNotifier,
      builder: (context, _, _) {
        final colors = context.appColors;

        // Get first patient's first reassurance for preview
        final firstPatient = AppState.patients.isNotEmpty
            ? AppState.patients.first
            : null;
        final recentMessage = firstPatient != null
            ? (AppState.getMessagesFor(firstPatient.id)[0]?.last)
            : null;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ────────────────────────────────────────────────
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${AppState.loggedInName.isNotEmpty ? AppState.loggedInName : AppState.patientName}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                          'How can we help?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: colors.textMed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppBackButton(
                    icon: Icons.settings_outlined,
                    color: colors.textLow,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(isCaregiver: true),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),

              // ── Today's Calm card ─────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [colors.shadow],
                ),
                clipBehavior: Clip.hardEdge,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sage left accent bar
                      Container(
                        width: 5,
                        color: colors.sage,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Today's reminder",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.sage,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Responding with kindness is always the right move.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: colors.textHigh,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.eco_outlined,
                                color: colors.sage,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Quick Actions section label ────────────────────────────────
              Text(
                'Ways we can help',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.textLow,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 10),

              // ── Full-width action cards ───────────────────────────────────
              DashboardActionCard(
                title: 'Get some guidance',
                subtitle: 'Suggested tips & approaches',
                icon: Icons.lightbulb_outline,
                color: colors.sage,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GuidanceTopicScreen()),
                ),
              ),

              const SizedBox(height: 10),

              DashboardActionCard(
                title: 'Send reassurance',
                subtitle: 'Create a comforting message',
                icon: Icons.favorite_border,
                color: colors.rose,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SendReassuranceScreen()),
                  );
                  setState(() {}); // Refresh after returning
                },
              ),

              const SizedBox(height: 10),

              DashboardActionCard(
                title: 'Take a breather',
                subtitle: 'A moment to breathe together',
                icon: Icons.air,
                color: colors.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BreatherIntroScreen(isCaregiver: true),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              DashboardActionCard(
                title: 'Manage patients',
                subtitle: 'View & edit profiles',
                icon: Icons.people_outline,
                color: colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManagePatientsScreen()),
                ),
              ),

              const SizedBox(height: 20),

              // ── Recent Reassurance card ───────────────────────────────────
              if (recentMessage != null) ...[
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [colors.shadow],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 5,
                              color: colors.rose,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Recently sent message',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.rose,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${recentMessage.headline}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: colors.textHigh,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (recentMessage.subtext.isEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${recentMessage.subtext}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.textMed,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        height: 28,
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            filledButtonTheme: FilledButtonThemeData(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: colors.rose.withValues(alpha: 0.15),
                                                foregroundColor: colors.rose,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                                minimumSize: const Size(0, 0),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                shadowColor: Colors.transparent,
                                                elevation: 0,
                                              ),
                                            ),
                                          ),
                                          child: FilledButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => const SendReassuranceScreen()),
                                            ),
                                            child: Text(
                                              'Send another',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: colors.rose,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 18,
                        right: 18,
                        child: Icon(
                          Icons.favorite_border,
                          color: colors.rose,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Voice input bar ───────────────────────────────────────────
              VoiceInputBar(color: colors.rose),

              const SizedBox(height: 16),

              // ── Caregiver mode badge ──────────────────────────────────────
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: colors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Caregiver View',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  },
);
  }
}
