// lib/app_state.dart
import 'package:flutter/material.dart';

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
  static double textScale = 1.0;
  static bool highContrastMode = false;
  static bool reducedMotion = false;
  static bool voiceGuidanceEnabled = true;
  static double narrationSpeed = 1.0;
  static double narrationVolume = 1.0;
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

  // Per-patient reassurance messages: patientId → situationIndex → data
  static Map<String, Map<int, ReassuranceData>> patientMessages = {
    defaultPatientId: _defaultMessages(),
  };

  static Map<int, ReassuranceData> _defaultMessages() => {
    0: ReassuranceData(
      headline: "You don't need to worry about that right now.",
      subtext: 'Everything is taken care of.',
    ),
    1: ReassuranceData(
      headline: "You're safe here with me.",
      subtext: 'This is a comfortable place.',
    ),
    2: ReassuranceData(
      headline: "I'm someone who cares about you.",
      subtext: "You're not alone.",
    ),
    3: ReassuranceData(
      headline: "That's okay, I'm happy to help.",
      subtext: 'We have time.',
    ),
  };

  static Map<int, ReassuranceData> getMessagesFor(String patientId) =>
      patientMessages[patientId] ?? _defaultMessages();

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Returns 'caregiver', 'patient', or null on failure.
  static String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final acc in _accounts) {
      if (acc.email == e && acc.password == password) {
        loggedInName = acc.name;
        loggedInEmail = acc.email;
        loggedInRole = acc.role;
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
    return role;
  }

  // ── Patient management ────────────────────────────────────────────────────

  static void addPatient({required String name, String notes = ''}) {
    final id = 'patient_${DateTime.now().millisecondsSinceEpoch}';
    patients.add(PatientProfile(id: id, name: name, notes: notes));
    patientMessages[id] = _defaultMessages();
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
        final existing = patientMessages[pid]![i];
        patientMessages[pid]![i] = ReassuranceData(
          headline: headline.trim().isNotEmpty
              ? headline.trim()
              : (existing?.headline ?? ''),
          subtext: subtext.trim().isNotEmpty
              ? subtext.trim()
              : (existing?.subtext ?? ''),
          hasRecording: hasRecording || (existing?.hasRecording ?? false),
          recordingDurationSeconds: recordingDurationSeconds > 0
              ? recordingDurationSeconds
              : (existing?.recordingDurationSeconds ?? 0),
          recordingPath: recordingPath ?? existing?.recordingPath,
        );
      }
    }
  }
}
