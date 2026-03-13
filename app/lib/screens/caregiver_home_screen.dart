// lib/screens/caregiver_home_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/voice_input_bar.dart';
import 'guidance_topic_screen.dart';
import 'send_reassurance_screen.dart';
import 'breather_intro_screen.dart';
import 'manage_patients_screen.dart';
import 'settings_screen.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          'Hi, ${AppState.loggedInName.isNotEmpty ? AppState.loggedInName : AppState.caregiverName}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: colors.textHigh,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How can we help today?',
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.textMed,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SettingsScreen(isCaregiver: true),
                      ),
                    ),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [colors.shadow],
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: colors.textMed,
                        size: 20,
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
                                      "Today's reminder:",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: colors.sage,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '"Responding with kindness is always the right move."',
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
                'Quick Actions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textLow,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 10),

              // ── Full-width action cards ───────────────────────────────────
              DashboardActionCard(
                title: 'Get some guidance',
                subtitle: 'Suggested phrases & approaches',
                icon: Icons.lightbulb_outline,
                color: colors.primary,
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
                color: colors.sage,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SendReassuranceScreen()),
                ),
              ),

              const SizedBox(height: 10),

              DashboardActionCard(
                title: 'Take a breather',
                subtitle: 'A moment to breathe together',
                icon: Icons.air,
                color: colors.rose,
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
                color: const Color(0xFF9B8EC4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManagePatientsScreen()),
                ),
              ),

              const SizedBox(height: 20),

              // ── Recent Reassurance card ───────────────────────────────────
              if (recentMessage != null) ...[
                SoftCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Recent message',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.textLow,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SendReassuranceScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: colors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"${recentMessage.headline}"',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: colors.textHigh,
                          height: 1.4,
                        ),
                      ),
                      if (recentMessage.subtext.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          recentMessage.subtext,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textMed,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Voice input bar ───────────────────────────────────────────
              VoiceInputBar(color: colors.primary),

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
  }

}
