// lib/screens/caregiver_home_screen.dart
import 'dart:async';
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
import 'patient_activity_screen.dart';
import 'settings_screen.dart';
import '../main.dart';
import '../services/firebase_service.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  static const _actionLabels = {
    kEventFeelUnsure: 'I feel unsure',
    kEventHearVoice: 'Hear a familiar voice',
    kEventBreather: 'Take a breather',
    kEventAppOpen: 'App opened',
  };

  List<PendingAlert> _liveAlerts = [];
  ReassuranceData? _recentMessage;
  StreamSubscription<List<PendingAlert>>? _alertsSub;
  StreamSubscription<Map<int, List<ReassuranceData>>>? _reassuranceSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeStreams();
    });
  }

  void _subscribeStreams() {
    _alertsSub?.cancel();
    _reassuranceSub?.cancel();

    final patientIds = AppState.patients.map((p) => p.id).toList();
    if (patientIds.isEmpty) return;

    _alertsSub = FirebaseService.caregiverAlertsStream(patientIds).listen((alerts) {
      if (mounted) setState(() => _liveAlerts = alerts);
    });

    _reassuranceSub = FirebaseService.patientReassurancesStream(patientIds.first).listen((msgs) {
      if (!mounted) return;
      AppState.patientMessages[patientIds.first] = msgs;
      // Get the most recent message from any situation
      ReassuranceData? recent;
      for (final list in msgs.values) {
        if (list.isNotEmpty) {
          recent = list.last;
          break;
        }
      }
      setState(() => _recentMessage = recent);
    });
  }

  @override
  void dispose() {
    _alertsSub?.cancel();
    _reassuranceSub?.cancel();
    super.dispose();
  }

  void _dismissAllAlerts() {
    for (final alert in _liveAlerts) {
      if (alert.firestoreId.isNotEmpty) {
        FirebaseService.markAlertSeen(alert.firestoreId);
      }
    }
    setState(() => _liveAlerts = []);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: settingsNotifier,
      builder: (context, _, __) {
        final colors = context.appColors;

        final pendingAlerts = _liveAlerts;
        final recentMessage = _recentMessage;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────────
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
                                  height: 1.05),
                            ),
                            const SizedBox(height: 8),
                            Text('How can we help?',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: colors.textMed)),
                          ],
                        ),
                      ),
                      AppBackButton(
                        icon: Icons.settings_outlined,
                        color: colors.textLow,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const SettingsScreen(isCaregiver: true))),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Today's alerts ────────────────────────────────────────
                  // Styled to match the "Today's reminder" card exactly
                  if (pendingAlerts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
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
                              Container(width: 5, color: colors.rose),
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
                                            // Label row — matches "Today's reminder" label style
                                            Row(
                                              children: [
                                                Text(
                                                  "Today's alerts",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: colors.rose,
                                                      letterSpacing: 0.8),
                                                ),
                                                const Spacer(),
                                                GestureDetector(
                                                  onTap: _dismissAllAlerts,
                                                  child: Text('Dismiss',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: colors.textLow,
                                                          fontWeight: FontWeight.w500)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // Alert rows
                                            Column(
                                              children: List<Widget>.generate(
                                                pendingAlerts.length,
                                                (i) {
                                                  final alert = pendingAlerts[i];
                                                  final label = _actionLabels[alert.action] ?? alert.action;
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: i < pendingAlerts.length - 1 ? 6 : 0),
                                                    child: Text.rich(
                                                      TextSpan(children: [
                                                        TextSpan(
                                                          text: alert.patientName,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              color: colors.textHigh,
                                                              fontSize: 14,
                                                              fontStyle: FontStyle.italic),
                                                        ),
                                                        TextSpan(
                                                          text: ' used "$label" ${alert.count}+ times',
                                                          style: TextStyle(
                                                              color: colors.textHigh,
                                                              fontSize: 14,
                                                              fontStyle: FontStyle.italic),
                                                        ),
                                                      ]),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // View activity button — matches "Send another" placement
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: SizedBox(
                                                height: 28,
                                                child: Theme(
                                                  data: Theme.of(context).copyWith(
                                                    filledButtonTheme: FilledButtonThemeData(
                                                      style: FilledButton.styleFrom(
                                                        backgroundColor:
                                                            colors.rose.withValues(alpha: 0.15),
                                                        foregroundColor: colors.rose,
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 12, vertical: 2),
                                                        minimumSize: const Size(0, 0),
                                                        tapTargetSize:
                                                            MaterialTapTargetSize.shrinkWrap,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        shadowColor: Colors.transparent,
                                                        elevation: 0,
                                                      ),
                                                    ),
                                                  ),
                                                  child: FilledButton(
                                                    onPressed: () {
                                                      final patientId = pendingAlerts.first.patientId;
                                                      final patient = AppState.patients.firstWhere(
                                                        (p) => p.id == patientId,
                                                        orElse: () => AppState.patients.first,
                                                      );
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              PatientActivityScreen(patient: patient),
                                                        ),
                                                      ).then((_) => setState(() {}));
                                                    },
                                                    child: Text('View activity',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                            color: colors.rose)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.notifications_outlined,
                                          color: colors.rose, size: 22),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── Today's reminder ──────────────────────────────────────
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
                          Container(width: 5, color: colors.sage),
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
                                        Text("Today's reminder",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: colors.sage,
                                                letterSpacing: 0.8)),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Responding with kindness is always the right move.',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                              color: colors.textHigh,
                                              height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.eco_outlined,
                                      color: colors.sage, size: 22),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text('Ways we can help',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textLow,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 10),

                  DashboardActionCard(
                    title: 'Get some guidance',
                    subtitle: 'Suggested tips & approaches',
                    icon: Icons.lightbulb_outline,
                    color: colors.sage,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const GuidanceTopicScreen())),
                  ),
                  const SizedBox(height: 10),
                  DashboardActionCard(
                    title: 'Send reassurance',
                    subtitle: 'Create a comforting message',
                    icon: Icons.favorite_border,
                    color: colors.rose,
                    onTap: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const SendReassuranceScreen()));
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  DashboardActionCard(
                    title: 'Take a breather',
                    subtitle: 'A moment to breathe together',
                    icon: Icons.air,
                    color: colors.primary,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const BreatherIntroScreen(isCaregiver: true))),
                  ),
                  const SizedBox(height: 10),
                  DashboardActionCard(
                    title: 'My care recipients',
                    subtitle: 'View & edit profiles',
                    icon: Icons.people_outline,
                    color: colors.teal,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const ManagePatientsScreen())),
                  ),


                  const SizedBox(height: 20),

                  // ── Recent Reassurance card ───────────────────────────────
                  if (recentMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
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
                                  Container(width: 5, color: colors.rose),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Recently sent message',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.rose,
                                                  letterSpacing: 0.8)),
                                          const SizedBox(height: 6),
                                          Text(recentMessage.headline,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                  color: colors.textHigh,
                                                  height: 1.4)),
                                          if (recentMessage.subtext.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(recentMessage.subtext,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: colors.textMed)),
                                            ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: SizedBox(
                                              height: 28,
                                              child: Theme(
                                                data: Theme.of(context).copyWith(
                                                  filledButtonTheme:
                                                      FilledButtonThemeData(
                                                    style: FilledButton.styleFrom(
                                                      backgroundColor: colors.rose
                                                          .withValues(alpha: 0.15),
                                                      foregroundColor: colors.rose,
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 12, vertical: 2),
                                                      minimumSize: const Size(0, 0),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize.shrinkWrap,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(20),
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
                                                        builder: (_) =>
                                                            const SendReassuranceScreen()),
                                                  ),
                                                  child: Text('Send another',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: colors.rose)),
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
                              child: Icon(Icons.favorite_border,
                                  color: colors.rose, size: 22),
                            ),
                          ],
                        ),
                      ),
                    ),

                  VoiceInputBar(color: colors.rose),
                  const SizedBox(height: 16),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined,
                              color: colors.primary, size: 14),
                          const SizedBox(width: 6),
                          Text('Caregiver View',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary)),
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