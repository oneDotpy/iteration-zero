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

  ReassuranceData({
    required this.headline,
    required this.subtext,
    this.hasRecording = false,
    this.recordingDurationSeconds = 0,
  });
}

class AppState {
  static const caregiverEmail = 'caregiver@gmail.com';
  static const caregiverPassword = 'caregiver';
  static const patientEmail = 'patient@gmail.com';
  static const patientPassword = 'patient';

  static const caregiverName = 'Alex';
  static const patientName = 'Margaret';

  // Set on login / sign-up
  static String loggedInName = '';
  static String loggedInRole = '';

  // Registered accounts: email → {name, password, role}
  static final Map<String, Map<String, String>> _registeredAccounts = {};

  // The logged-in patient account always maps to this ID
  static const defaultPatientId = 'patient_default';

  // Caregiver's patient list
  static List<PatientProfile> patients = [
    PatientProfile(id: defaultPatientId, name: patientName),
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

  /// Returns 'caregiver', 'patient', or null.
  static String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    if (e == caregiverEmail && password == caregiverPassword) {
      loggedInName = caregiverName;
      loggedInRole = 'caregiver';
      return 'caregiver';
    }
    if (e == patientEmail && password == patientPassword) {
      loggedInName = patientName;
      loggedInRole = 'patient';
      return 'patient';
    }
    // Check dynamically registered accounts
    final account = _registeredAccounts[e];
    if (account != null && account['password'] == password) {
      loggedInName = account['name']!;
      loggedInRole = account['role']!;
      return account['role'];
    }
    return null;
  }

  /// Registers a new account. Returns an error string, or null on success.
  static String? register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    final e = email.trim().toLowerCase();
    if (e == caregiverEmail || e == patientEmail || _registeredAccounts.containsKey(e)) {
      return 'An account with that email already exists.';
    }
    _registeredAccounts[e] = {'name': name, 'password': password, 'role': role};
    loggedInName = name;
    loggedInRole = role;
    return null; // success
  }

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
        );
      }
    }
  }
}
