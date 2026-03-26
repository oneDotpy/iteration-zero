// lib/app_state.dart
import 'package:connection_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class _UserAccount {
  final String email;
  final String password;
  final String name;
  final String role;
  _UserAccount({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
}

class AppSettings {
  static ThemeMode themeMode = ThemeMode.light;
  static bool narrationEnabled = true;
  static double textScale = 1.2;
  static bool highContrastMode = false;
  static bool reducedMotion = false;
  static bool voiceGuidanceEnabled = true;
  static double narrationSpeed = 1.0;
  static double narrationVolume = 1.0;

  static final Map<String, Map<String, dynamic>> _accountSettings = {};

  static void saveForCurrentAccount() {
    final email = AppState.loggedInEmail;
    if (email.isEmpty) return;
    _accountSettings[email] = {
      'themeMode': themeMode.index,
      'narrationEnabled': narrationEnabled,
      'textScale': textScale,
      'highContrastMode': highContrastMode,
      'reducedMotion': reducedMotion,
      'voiceGuidanceEnabled': voiceGuidanceEnabled,
      'narrationSpeed': narrationSpeed,
      'narrationVolume': narrationVolume,
    };
  }

  static void loadForCurrentAccount() {
    final email = AppState.loggedInEmail;
    if (email.isEmpty) return;
    final s = _accountSettings[email];
    if (s == null) return;
    themeMode = ThemeMode.values[s['themeMode'] ?? 0];
    narrationEnabled = s['narrationEnabled'] ?? true;
    textScale = (s['textScale'] ?? 1.0).toDouble();
    highContrastMode = s['highContrastMode'] ?? false;
    reducedMotion = s['reducedMotion'] ?? false;
    voiceGuidanceEnabled = s['voiceGuidanceEnabled'] ?? true;
    narrationSpeed = (s['narrationSpeed'] ?? 1.0).toDouble();
    narrationVolume = (s['narrationVolume'] ?? 1.0).toDouble();
  }
}

// ── Usage tracking ────────────────────────────────────────────────────────────

const String kEventAppOpen = 'app_open';
const String kEventFeelUnsure = 'feel_unsure';
const String kEventHearVoice = 'hear_voice';
const String kEventBreather = 'breather';

class UsageEvent {
  final String action;
  final DateTime timestamp;
  UsageEvent({required this.action, required this.timestamp});
}

/// An alert that fired when a threshold was crossed.
/// [seenOnHome] is true once the caregiver dismisses it from the home card —
/// it stays in the list so the activity screen can still show it.
class PendingAlert {
  final String action;
  final int count;
  final DateTime firedAt;
  bool seenOnHome;
  final String firestoreId;
  final String patientId;
  final String patientName;

  PendingAlert({
    required this.action,
    required this.count,
    required this.firedAt,
    this.seenOnHome = false,
    this.firestoreId = '',
    this.patientId = '',
    this.patientName = '',
  });
}

class PatientUsageStats {
  final List<UsageEvent> events = [];
  Map<String, int> alertThresholds = {
    kEventFeelUnsure: 5,
    kEventHearVoice: 5,
    kEventBreather: 5,
  };
  final Set<String> _notifiedToday = {};
  final List<PendingAlert> _alerts = [];

  /// All alerts — used by activity screen (shows everything).
  List<PendingAlert> get pendingAlerts => List.unmodifiable(_alerts);

  /// Only alerts not yet dismissed from home — used by home screen card.
  List<PendingAlert> get unseenAlerts =>
      _alerts.where((a) => !a.seenOnHome).toList();

  /// Mark all alerts as seen on home (hides them from home card).
  void dismissFromHome() {
    for (final a in _alerts) {
      a.seenOnHome = true;
    }
  }

  /// Fully remove all alerts (used when clearing activity screen if needed).
  void clearPendingAlerts() => _alerts.clear();

  void log(String action) =>
      events.add(UsageEvent(action: action, timestamp: DateTime.now()));

  int countToday(String action) {
    final today = _startOfToday();
    return events
        .where((e) => e.action == action && !e.timestamp.isBefore(today))
        .length;
  }

  int countTotal(String action) =>
      events.where((e) => e.action == action).length;

  String? checkThreshold(String action) {
    final threshold = alertThresholds[action];
    if (threshold == null) return null;
    final todayKey = '${action}_${_startOfToday().toIso8601String()}';
    if (_notifiedToday.contains(todayKey)) return null;
    if (countToday(action) >= threshold) {
      _notifiedToday.add(todayKey);
      _alerts.add(PendingAlert(
        action: action,
        count: threshold,
        firedAt: DateTime.now(),
      ));
      return action;
    }
    return null;
  }

  static DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Map<String, List<int>> weeklyBreakdown() {
    final result = <String, List<int>>{};
    for (final action in [kEventFeelUnsure, kEventHearVoice, kEventBreather, kEventAppOpen]) {
      final counts = List<int>.filled(7, 0);
      for (final e in events) {
        final daysAgo = DateTime.now().difference(e.timestamp).inDays;
        if (e.action == action && daysAgo < 7) {
          counts[6 - daysAgo]++;
        }
      }
      result[action] = counts;
    }
    return result;
  }
}

class PatientProfile {
  final String id;
  String name;
  String notes;
  String? imagePath;

  PatientProfile({required this.id, required this.name, this.notes = '', this.imagePath});
}

class ReassuranceData {
  String headline;
  String subtext;
  bool hasRecording;
  int recordingDurationSeconds;
  String? recordingPath;
  String? mediaPath;
  bool isVideo;

  ReassuranceData({
    required this.headline,
    required this.subtext,
    this.hasRecording = false,
    this.recordingDurationSeconds = 0,
    this.recordingPath,
    this.mediaPath,
    this.isVideo = false,
  });
}

class AppState {
  static const _demoCaregiverEmail = 'caregiver@gmail.com';
  static const _demoCaregiverPassword = 'caregiver';
  static const _demoCaregiverName = 'Alex';
  static const _demoPatientEmail = 'patient@gmail.com';
  static const _demoPatientPassword = 'patient';
  static const _demoPatientName = 'Margaret';

  static final List<_UserAccount> _accounts = [
    _UserAccount(
      email: _demoCaregiverEmail,
      password: _demoCaregiverPassword,
      name: _demoCaregiverName,
      role: 'caregiver',
    ),
    _UserAccount(
      email: _demoPatientEmail,
      password: _demoPatientPassword,
      name: _demoPatientName,
      role: 'patient',
    ),
  ];

  static String loggedInName = '';
  static String loggedInEmail = '';
  static String loggedInRole = '';

  static String get caregiverName =>
      loggedInName.isNotEmpty ? loggedInName : _demoCaregiverName;
  static String get patientName =>
      loggedInName.isNotEmpty ? loggedInName : _demoPatientName;

  static const String defaultPatientId = 'patient_default';
  static String _activePatientId = defaultPatientId;

  static void overrideDefaultPatientId(String id) {
    _activePatientId = id;
  }

  static String get activeDefaultPatientId => _activePatientId;

  static List<PatientProfile> patients = [
    PatientProfile(id: defaultPatientId, name: _demoPatientName),
  ];

  static Map<String, PatientUsageStats> patientUsageStats = {
    defaultPatientId: PatientUsageStats(),
  };

  static PatientUsageStats getUsageFor(String patientId) =>
      patientUsageStats.putIfAbsent(patientId, PatientUsageStats.new);

  static void logPatientEvent(String action, {String? patientId}) {
    final stats = getUsageFor(patientId ?? defaultPatientId);
    stats.log(action);
    stats.checkThreshold(action);
  }

  static Map<String, Map<int, List<ReassuranceData>>> patientMessages = {
    defaultPatientId: _defaultMessages(),
  };

  static Map<int, List<ReassuranceData>> _defaultMessages() => {
    0: [
      ReassuranceData(
        headline: "You don't need to worry about that right now.",
        subtext: 'Everything is taken care of.',
      ),
    ],
    1: [
      ReassuranceData(
        headline: "You're safe here with me.",
        subtext: 'This is a comfortable place.',
      ),
    ],
    2: [
      ReassuranceData(
        headline: "I'm someone who cares about you.",
        subtext: "You're not alone.",
      ),
    ],
    3: [
      ReassuranceData(
        headline: "That's okay, I'm happy to help.",
        subtext: 'We have time.',
      ),
    ],
  };

  static Map<int, List<ReassuranceData>> defaultMessagesMap() => _defaultMessages();

  static Map<int, List<ReassuranceData>> getMessagesFor(String patientId) =>
      patientMessages[patientId] ?? _defaultMessages();

  static bool hasVoiceRecordingFor(String patientId) {
    final messages = patientMessages[patientId];
    if (messages == null) return false;
    return messages.values.any(
      (list) => list.any((m) => m.hasRecording && m.recordingPath != null),
    );
  }

  static ReassuranceData getRandomMessageFor({
    required String patientId,
    required int situationIndex,
  }) {
    final messagesBySituation = getMessagesFor(patientId);
    final allOptions = messagesBySituation[situationIndex] ?? [];
    final withRecording = allOptions
        .where((m) => m.hasRecording && m.recordingPath != null)
        .toList();
    final options = withRecording.isNotEmpty ? withRecording : allOptions;
    if (options.isEmpty) {
      return ReassuranceData(
        headline: "You're safe.",
        subtext: 'Take a slow breath with me.',
      );
    }
    final random = Random();
    return options[random.nextInt(options.length)];
  }

  static String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final acc in _accounts) {
      if (acc.email == e && acc.password == password) {
        loggedInName = acc.name;
        loggedInEmail = acc.email;
        loggedInRole = acc.role;
        if (!AppSettings._accountSettings.containsKey(acc.email)) {
          AppSettings.themeMode = ThemeMode.light;
          AppSettings.highContrastMode = false;
          AppSettings.reducedMotion = false;
          AppSettings.saveForCurrentAccount();
        }
        AppSettings.loadForCurrentAccount();
        try {
          themeNotifier.value = AppSettings.themeMode;
        } catch (_) {}
        return acc.role;
      }
    }
    return null;
  }

  static String register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) {
    final e = email.trim().toLowerCase();
    final displayName = name.trim().isNotEmpty
        ? name.trim()
        : (role == 'caregiver' ? 'Caregiver' : 'Patient');
    _accounts.add(
        _UserAccount(email: e, password: password, name: displayName, role: role));
    loggedInName = displayName;
    loggedInEmail = e;
    loggedInRole = role;
    AppSettings.saveForCurrentAccount();
    return role;
  }

  static void addPatient({required String name, String notes = ''}) {
    final id = 'patient_${DateTime.now().millisecondsSinceEpoch}';
    patients.add(PatientProfile(id: id, name: name, notes: notes));
    patientMessages[id] = _defaultMessages();
    patientUsageStats[id] = PatientUsageStats();
  }

  static void completeSignup({required String name, required bool isCaregiver}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    loggedInName = trimmed;
    if (!isCaregiver) {
      final index = patients.indexWhere((p) => p.id == defaultPatientId);
      if (index >= 0) {
        patients[index].name = trimmed;
      }
    }
  }

  static void resetDisplayNamesToDefaults() {}

  static void removePatient(String id) {
    patients.removeWhere((p) => p.id == id);
    patientMessages.remove(id);
    patientUsageStats.remove(id);
  }

  static void saveReassurance({
    required List<String> patientIds,
    required List<int> situationIndexes,
    required String headline,
    required String subtext,
    required bool hasRecording,
    required int recordingDurationSeconds,
    String? recordingPath,
    String? mediaPath,
    bool isVideo = false,
  }) {
    for (final pid in patientIds) {
      patientMessages.putIfAbsent(pid, _defaultMessages);
      for (final i in situationIndexes) {
        final existingList =
            patientMessages[pid]!.putIfAbsent(i, () => <ReassuranceData>[]);
        final trimmedHeadline = headline.trim();
        final trimmedSubtext = subtext.trim();
        final defaultSubtext = _defaultMessages()[i]?.first.subtext ?? '';
        existingList.add(
          ReassuranceData(
            headline: trimmedHeadline,
            subtext:
                trimmedSubtext.isNotEmpty ? trimmedSubtext : defaultSubtext,
            hasRecording: hasRecording,
            recordingDurationSeconds:
                hasRecording ? recordingDurationSeconds : 0,
            recordingPath: hasRecording ? recordingPath : null,
            mediaPath: mediaPath,
            isVideo: isVideo,
          ),
        );
      }
    }
  }
}
