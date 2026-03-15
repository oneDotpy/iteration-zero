// lib/app_state.dart
import 'package:flutter/material.dart';
import 'dart:math';

class _UserAccount {
  final String email;
  final String password;
  final String name;
  final String role; // 'caregiver' or 'patient'
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

  // Store settings per account (by email)
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

class PatientProfile {
  final String id;
  String name;
  String notes;

  PatientProfile({required this.id, required this.name, this.notes = ''});
}

class ReassuranceData {
  String headline;
  String subtext;
  bool hasRecording;
  int recordingDurationSeconds;
  String? recordingPath;

  ReassuranceData({
    required this.headline,
    required this.subtext,
    this.hasRecording = false,
    this.recordingDurationSeconds = 0,
    this.recordingPath,
  });
}

class AppState {
  // ── Demo credentials ──────────────────────────────────────────────────────
  static const _demoCaregiverEmail = 'caregiver@gmail.com';
  static const _demoCaregiverPassword = 'caregiver';
  static const _demoCaregiverName = 'Alex';
  static const _demoPatientEmail = 'patient@gmail.com';
  static const _demoPatientPassword = 'patient';
  static const _demoPatientName = 'Margaret';

  // ── Dynamic account store ─────────────────────────────────────────────────
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

  // ── Session state ─────────────────────────────────────────────────────────
  static String loggedInName = '';
  static String loggedInEmail = '';
  static String loggedInRole = '';

  // ── Name getters (dynamic after login/register) ───────────────────────────
  static String get caregiverName =>
      loggedInName.isNotEmpty ? loggedInName : _demoCaregiverName;
  static String get patientName =>
      loggedInName.isNotEmpty ? loggedInName : _demoPatientName;

  // The logged-in patient account always maps to this ID for reassurance lookups
  static const defaultPatientId = 'patient_default';

  // ── Patient list ──────────────────────────────────────────────────────────
  static List<PatientProfile> patients = [
    PatientProfile(id: defaultPatientId, name: _demoPatientName),
  ];

  // Per-patient reassurance messages: patientId -> situationIndex -> message list
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

  static Map<int, List<ReassuranceData>> getMessagesFor(String patientId) =>
      patientMessages[patientId] ?? _defaultMessages();

  static ReassuranceData getRandomMessageFor({
    required String patientId,
    required int situationIndex,
  }) {
    final messagesBySituation = getMessagesFor(patientId);
    final options =
        messagesBySituation[situationIndex] ?? _defaultMessages()[situationIndex] ?? const [];
    if (options.isEmpty) {
      return ReassuranceData(
        headline: "You're safe.",
        subtext: 'Take a slow breath with me.',
      );
    }
    final random = Random();
    return options[random.nextInt(options.length)];
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Returns 'caregiver', 'patient', or null on failure.
  static String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final acc in _accounts) {
      if (acc.email == e && acc.password == password) {
        loggedInName = acc.name;
        loggedInEmail = acc.email;
        loggedInRole = acc.role;
        // Load settings for this account
        AppSettings.loadForCurrentAccount();
        return acc.role;
      }
    }
    return null;
  }

  /// Registers a new account and logs them in. Returns the role string.
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
    // Save default settings for new account
    AppSettings.saveForCurrentAccount();
    return role;
  }

  // ── Patient management ────────────────────────────────────────────────────

  static void addPatient({required String name, String notes = ''}) {
    final id = 'patient_${DateTime.now().millisecondsSinceEpoch}';
    patients.add(PatientProfile(id: id, name: name, notes: notes));
    patientMessages[id] = _defaultMessages();
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

  static void resetDisplayNamesToDefaults() {
    // no-op: names are managed via loggedInName and _accounts
  }

  static void removePatient(String id) {
    patients.removeWhere((p) => p.id == id);
    patientMessages.remove(id);
  }

  static void saveReassurance({
    required List<String> patientIds,
    required List<int> situationIndexes,
    required String headline,
    required String subtext,
    required bool hasRecording,
    required int recordingDurationSeconds,
    String? recordingPath,
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
          ),
        );
      }
    }
  }
}
