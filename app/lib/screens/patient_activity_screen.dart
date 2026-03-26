// lib/screens/patient_activity_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_icon_button.dart';
import '../services/firebase_service.dart';

class PatientActivityScreen extends StatefulWidget {
  final PatientProfile patient;
  const PatientActivityScreen({super.key, required this.patient});

  @override
  State<PatientActivityScreen> createState() => _PatientActivityScreenState();
}

class _PatientActivityScreenState extends State<PatientActivityScreen> {
  late PatientUsageStats _stats;
  StreamSubscription<List<UsageEvent>>? _eventsSub;

  static const _actions = [
    _ActionMeta(key: kEventFeelUnsure, label: 'I feel unsure', icon: Icons.help_outline_rounded),
    _ActionMeta(key: kEventHearVoice, label: 'Hear a familiar voice', icon: Icons.volume_up_outlined),
    _ActionMeta(key: kEventBreather, label: 'Take a breather', icon: Icons.air),
    _ActionMeta(key: kEventAppOpen, label: 'App opens', icon: Icons.phone_android_outlined),
  ];

  static const _actionLabels = {
    kEventFeelUnsure: 'I feel unsure',
    kEventHearVoice: 'Hear a familiar voice',
    kEventBreather: 'Take a breather',
    kEventAppOpen: 'App opened',
  };

  @override
  void initState() {
    super.initState();
    _stats = AppState.getUsageFor(widget.patient.id);
    _eventsSub = FirebaseService.patientEventsStream(widget.patient.id).listen((events) {
      if (!mounted) return;
      final updated = PatientUsageStats();
      updated.alertThresholds = Map.from(_stats.alertThresholds);
      for (final e in events) {
        updated.events.add(e);
      }
      setState(() => _stats = updated);
    });
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }

  void _editThreshold(BuildContext context, AppColors colors, _ActionMeta action) {
    if (action.key == kEventAppOpen) return;
    final current = _stats.alertThresholds[action.key] ?? 5;
    int value = current;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: colors.background,
          title: Text('Alert threshold',
              style: TextStyle(color: colors.textHigh, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notify when "${action.label}" is used this many times in a day:',
                style: TextStyle(fontSize: 14, color: colors.textMed),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: value > 1 ? () => setLocal(() => value--) : null,
                    icon: Icon(Icons.remove_circle_outline, color: colors.teal),
                    iconSize: 32,
                  ),
                  const SizedBox(width: 12),
                  Text('$value',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: colors.textHigh)),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: value < 50 ? () => setLocal(() => value++) : null,
                    icon: Icon(Icons.add_circle_outline, color: colors.teal),
                    iconSize: 32,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: colors.textMed)),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _stats.alertThresholds[action.key] = value);
                FirebaseService.updateAlertThreshold(widget.patient.id, action.key, value);
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(DateTime firedAt) {
    final diff = DateTime.now().difference(firedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return 'Earlier today';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final weekly = _stats.weeklyBreakdown();
    final actionColors = [colors.rose, colors.sage, colors.primary, colors.teal];
    final alerts = _stats.pendingAlerts.toList();

    return Scaffold(
      backgroundColor: colors.tealLight,
      appBar: AppBar(
        backgroundColor: colors.tealLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: colors.teal,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.patient.name}\'s Activity',
          style: TextStyle(
              color: colors.textHigh, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Today's alerts ────────────────────────────────────────────
              if (alerts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: "TODAY'S ALERTS", colors: colors),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.background,
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
                                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.notifications_outlined,
                                              color: colors.rose, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${alerts.length} threshold${alerts.length == 1 ? '' : 's'} crossed today',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: colors.rose,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Column(
                                        children: List<Widget>.generate(
                                          alerts.length,
                                          (i) {
                                            final alert = alerts[i];
                                            final label = _actionLabels[alert.action] ??
                                                alert.action;
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 7,
                                                    height: 7,
                                                    margin: const EdgeInsets.only(top: 5),
                                                    decoration: BoxDecoration(
                                                        color: colors.rose,
                                                        shape: BoxShape.circle),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text.rich(TextSpan(children: [
                                                          TextSpan(
                                                            text: '"$label"',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                color: colors.textHigh,
                                                                fontSize: 14),
                                                          ),
                                                          TextSpan(
                                                            text: ' used ${alert.count}+ times',
                                                            style: TextStyle(
                                                                color: colors.textMed,
                                                                fontSize: 14),
                                                          ),
                                                        ])),
                                                        const SizedBox(height: 2),
                                                        Text(_timeLabel(alert.firedAt),
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: colors.textLow)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
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

              // ── Today summary ─────────────────────────────────────────────
              _SectionLabel(label: "TODAY", colors: colors),
              const SizedBox(height: 10),
              Row(
                children: List<Widget>.generate(_actions.length, (i) {
                  final action = _actions[i];
                  final count = _stats.countToday(action.key);
                  final color = actionColors[i];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < _actions.length - 1 ? 8 : 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [colors.shadow],
                        ),
                        child: Column(
                          children: [
                            Icon(action.icon, color: color, size: 20),
                            const SizedBox(height: 6),
                            Text('$count',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: color)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: List<Widget>.generate(_actions.length, (i) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: actionColors[i], shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(_actions[i].label,
                          style: TextStyle(fontSize: 11, color: colors.textMed)),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 24),

              // ── Weekly bar chart ──────────────────────────────────────────
              _SectionLabel(label: "LAST 7 DAYS", colors: colors),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [colors.shadow],
                ),
                child: _WeeklyBarChart(
                  weekly: weekly,
                  actions: _actions,
                  actionColors: actionColors,
                  colors: colors,
                ),
              ),

              const SizedBox(height: 24),

              // ── Alert thresholds ──────────────────────────────────────────
              _SectionLabel(label: "ALERT THRESHOLDS", colors: colors),
              const SizedBox(height: 4),
              Text(
                'Get notified when an action is used this many times in one day.',
                style: TextStyle(fontSize: 13, color: colors.textMed),
              ),
              const SizedBox(height: 12),
              Column(
                children: List<Widget>.generate(_actions.length, (i) {
                  final action = _actions[i];
                  if (action.key == kEventAppOpen) return const SizedBox.shrink();
                  final threshold = _stats.alertThresholds[action.key] ?? 5;
                  final color = actionColors[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [colors.shadow],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(action.icon, color: color, size: 18),
                        ),
                        title: Text(action.label,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colors.textHigh)),
                        subtitle: Text('Alert after $threshold times',
                            style: TextStyle(fontSize: 12, color: colors.textMed)),
                        trailing: GestureDetector(
                          onTap: () => _editThreshold(context, colors, action),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.tealLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: colors.teal.withValues(alpha: 0.3)),
                            ),
                            child: Text('Edit',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colors.teal)),
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ActionMeta {
  final String key;
  final String label;
  final IconData icon;
  const _ActionMeta({required this.key, required this.label, required this.icon});
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColors colors;
  const _SectionLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.textLow,
            letterSpacing: 1.2));
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final Map<String, List<int>> weekly;
  final List<_ActionMeta> actions;
  final List<Color> actionColors;
  final AppColors colors;

  const _WeeklyBarChart({
    required this.weekly,
    required this.actions,
    required this.actionColors,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Find the max *total* stacked count across all days so bars never overflow
    int maxVal = 1;
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      int dayTotal = 0;
      for (final action in actions) {
        final counts = weekly[action.key] ?? List.filled(7, 0);
        dayTotal += counts[dayIndex];
      }
      if (dayTotal > maxVal) maxVal = dayTotal;
    }

    const chartHeight = 120.0;

    final now = DateTime.now();
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final labels = List<String>.generate(7, (i) {
      if (i == 6) return 'Today';
      final d = now.subtract(Duration(days: 6 - i));
      return dayNames[d.weekday % 7];
    });

    return Column(
      children: [
        SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List<Widget>.generate(7, (dayIndex) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List<Widget>.generate(actions.length, (i) {
                      final action = actions[i];
                      final counts = weekly[action.key] ?? List.filled(7, 0);
                      final count = counts[dayIndex];
                      if (count == 0) return const SizedBox.shrink();
                      // Scale by total so stacked bars never exceed chartHeight
                      final barHeight =
                          ((count / maxVal) * chartHeight).clamp(0.0, chartHeight);
                      return Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: actionColors[i].withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List<Widget>.generate(7, (i) {
            return Expanded(
              child: Text(labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: i == 6 ? colors.teal : colors.textLow,
                      fontWeight: i == 6 ? FontWeight.w700 : FontWeight.w400)),
            );
          }),
        ),
      ],
    );
  }
}