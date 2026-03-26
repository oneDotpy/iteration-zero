// lib/services/firebase_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../app_state.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static final _messaging = FirebaseMessaging.instance;

  // ── Auth ────────────────────────────────────────────────────────────────────

  /// Returns the role ('caregiver' or 'patient') on success, null on failure.
  static Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final uid = cred.user!.uid;
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      AppState.loggedInName = data['name'] ?? '';
      AppState.loggedInEmail = email.trim().toLowerCase();
      AppState.loggedInRole = data['role'] ?? '';
      await _loadPatientsIntoAppState(uid, data['role']);
      await _requestNotificationPermission(uid);
      return data['role'] as String?;
    } on FirebaseAuthException {
      return null;
    }
  }

  /// Creates a new account and logs in. Returns the role string.
  static Future<String> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final uid = cred.user!.uid;
    final displayName = name.trim().isNotEmpty ? name.trim()
        : (role == 'caregiver' ? 'Caregiver' : 'Patient');

    await _db.collection('users').doc(uid).set({
      'name': displayName,
      'email': email.trim().toLowerCase(),
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    AppState.loggedInName = displayName;
    AppState.loggedInEmail = email.trim().toLowerCase();
    AppState.loggedInRole = role;
    AppState.patients.clear();
    AppState.patientMessages.clear();
    AppState.patientUsageStats.clear();

    if (role == 'patient') {
      // Patient's own UID is their patient doc ID
      await _db.collection('patients').doc(uid).set({
        'name': displayName,
        'notes': '',
        'imageUrl': null,
        'caregiverId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'alertThresholds': {
          kEventFeelUnsure: 5,
          kEventHearVoice: 5,
          kEventBreather: 5,
        },
      });
      AppState.overrideDefaultPatientId(uid);
      AppState.patients.clear();
      AppState.patients.add(PatientProfile(id: uid, name: displayName));
      AppState.patientUsageStats[uid] = PatientUsageStats();
      AppState.patientMessages[uid] = AppState.defaultMessagesMap();
    }

    await _requestNotificationPermission(uid);
    return role;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    AppState.loggedInName = '';
    AppState.loggedInEmail = '';
    AppState.loggedInRole = '';
    AppState.patients.clear();
    AppState.patientMessages.clear();
    AppState.patientUsageStats.clear();
  }

  // ── Patients ────────────────────────────────────────────────────────────────

  /// Links a patient account to a caregiver by the patient's email.
  /// Returns the patient's [PatientProfile] on success, or throws a
  /// descriptive [Exception] the UI can show directly.
  static Future<PatientProfile> linkPatient({
    required String patientEmail,
    required String caregiverId,
  }) async {
    final email = patientEmail.trim().toLowerCase();

    // 1. Find the user with that email and role=patient
    final userQuery = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'patient')
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('No patient account found for $email.\nAsk them to create an account first.');
    }

    final patientUid = userQuery.docs.first.id;
    final patientData = userQuery.docs.first.data();

    // 2. Make sure they're not already linked to someone else
    final patientDoc = await _db.collection('patients').doc(patientUid).get();
    if (patientDoc.exists) {
      final existingCaregiver = patientDoc.data()?['caregiverId'];
      if (existingCaregiver != null && existingCaregiver != caregiverId) {
        // Check if the old caregiver still exists
        final oldCaregiverDoc = await _db.collection('users').doc(existingCaregiver).get();
        if (oldCaregiverDoc.exists) {
          throw Exception('This patient is already linked to another caregiver.');
        }
        // Old caregiver no longer exists, so allow re-linking
      }
    }

    // 3. Set caregiverId on the patient doc
    await _db.collection('patients').doc(patientUid).update({
      'caregiverId': caregiverId,
    });

    final profile = PatientProfile(
      id: patientUid,
      name: patientData['name'] ?? email,
    );
    return profile;
  }

  static Future<void> removePatient(String patientId) async {
    await _db.collection('patients').doc(patientId).delete();
  }

  static Future<void> updatePatient(PatientProfile patient) async {
    final updates = <String, dynamic>{
      'name': patient.name,
      'notes': patient.notes,
    };
    if (patient.imagePath != null) {
      final url = await _uploadFile(patient.imagePath!, 'patients/${patient.id}/avatar');
      updates['imageUrl'] = url;
      patient.imagePath = url;
    }
    await _db.collection('patients').doc(patient.id).update(updates);
  }

  // ── Reassurance messages ────────────────────────────────────────────────────

  static Future<void> saveReassurance({
    required List<String> patientIds,
    required List<int> situationIndexes,
    required String headline,
    required String subtext,
    required bool hasRecording,
    String? recordingPath,
    String? mediaPath,
    bool isVideo = false,
  }) async {
    for (final pid in patientIds) {
      String? recordingUrl;
      String? mediaUrl;

      if (hasRecording && recordingPath != null) {
        recordingUrl = await _uploadFile(recordingPath, 'patients/$pid/recordings/${DateTime.now().millisecondsSinceEpoch}');
      }
      if (mediaPath != null) {
        mediaUrl = await _uploadFile(mediaPath, 'patients/$pid/media/${DateTime.now().millisecondsSinceEpoch}');
      }

      // Store the last sent message on the patient doc for quick home-screen display
      await _db.collection('patients').doc(pid).set({
        'lastReassurance': {
          'headline': headline.trim(),
          'subtext': subtext.trim(),
          'sentAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      for (final i in situationIndexes) {
        await _db
            .collection('patients')
            .doc(pid)
            .collection('reassurances')
            .add({
          'situationIndex': i,
          'headline': headline.trim(),
          'subtext': subtext.trim(),
          'hasRecording': hasRecording,
          'recordingUrl': recordingUrl,
          'mediaUrl': mediaUrl,
          'isVideo': isVideo,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Also update local AppState
        AppState.patientMessages.putIfAbsent(pid, AppState.defaultMessagesMap);
        AppState.patientMessages[pid]!.putIfAbsent(i, () => []);
        AppState.patientMessages[pid]![i]!.add(ReassuranceData(
          headline: headline.trim(),
          subtext: subtext.trim(),
          hasRecording: hasRecording,
          recordingPath: recordingUrl ?? recordingPath,
          mediaPath: mediaUrl ?? mediaPath,
          isVideo: isVideo,
        ));
      }
    }
  }

  // ── Usage events ────────────────────────────────────────────────────────────

  static Future<void> logEvent(String patientId, String action) async {
    // Log locally AND check threshold here — patient_home_screen must NOT call
    // AppState.logPatientEvent separately or the _notifiedToday guard fires twice.
    final stats = AppState.getUsageFor(patientId);
    stats.log(action);
    await _db
        .collection('patients')
        .doc(patientId)
        .collection('events')
        .add({
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
    });
    final triggered = stats.checkThreshold(action);
    if (triggered != null) {
      await _sendThresholdNotification(patientId, action, stats.alertThresholds[action] ?? 5);
    }
  }

  static Future<void> updateAlertThreshold(
    String patientId,
    String action,
    int value,
  ) async {
    await _db.collection('patients').doc(patientId).update({
      'alertThresholds.$action': value,
    });
    AppState.getUsageFor(patientId).alertThresholds[action] = value;
  }

  // ── Loading helpers ─────────────────────────────────────────────────────────

  static Future<void> _loadPatientsIntoAppState(String uid, String? role) async {
    AppState.patients.clear();
    AppState.patientMessages.clear();
    AppState.patientUsageStats.clear();

    // Caregiver: all patients linked to them. Patient: their own doc by UID.
    List<DocumentSnapshot<Map<String, dynamic>>> docs;
    if (role == 'caregiver') {
      final snap = await _db.collection('patients').where('caregiverId', isEqualTo: uid).get();
      docs = snap.docs;
    } else {
      final doc = await _db.collection('patients').doc(uid).get();
      docs = doc.exists ? [doc] : [];
    }

    for (final doc in docs) {
      final data = doc.data();
      if (data == null) continue;
      final profile = PatientProfile(
        id: doc.id,
        name: data['name'] ?? '',
        notes: data['notes'] ?? '',
        imagePath: data['imageUrl'],
      );
      AppState.patients.add(profile);

      // Load reassurance messages
      final reassurances = await doc.reference.collection('reassurances').get();
      final msgMap = <int, List<ReassuranceData>>{};
      for (final r in reassurances.docs) {
        final d = r.data();
        final idx = (d['situationIndex'] as int?) ?? 0;
        msgMap.putIfAbsent(idx, () => []);
        msgMap[idx]!.add(ReassuranceData(
          headline: d['headline'] ?? '',
          subtext: d['subtext'] ?? '',
          hasRecording: d['hasRecording'] ?? false,
          recordingPath: d['recordingUrl'],
          mediaPath: d['mediaUrl'],
          isVideo: d['isVideo'] ?? false,
        ));
      }
      AppState.patientMessages[doc.id] = msgMap;

      // Load usage events
      final stats = PatientUsageStats();
      final thresholds = data['alertThresholds'] as Map<String, dynamic>? ?? {};
      for (final e in thresholds.entries) {
        stats.alertThresholds[e.key] = (e.value as num).toInt();
      }
      final events = await doc.reference.collection('events')
          .orderBy('timestamp', descending: false)
          .get();
      for (final ev in events.docs) {
        final d = ev.data();
        final ts = (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        stats.events.add(UsageEvent(action: d['action'] ?? '', timestamp: ts));
      }
      AppState.patientUsageStats[doc.id] = stats;

      // Set defaultPatientId alias
      if (AppState.patients.length == 1) {
        AppState.overrideDefaultPatientId(doc.id);
      }
    }
  }

  // ── Real-time streams ───────────────────────────────────────────────────────

  /// Live stream of usage events for a patient.
  static Stream<List<UsageEvent>> patientEventsStream(String patientId) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('events')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return UsageEvent(
                action: data['action'] ?? '',
                timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            }).toList());
  }

  /// Live stream of all reassurances for a patient, grouped by situationIndex.
  static Stream<Map<int, List<ReassuranceData>>> patientReassurancesStream(String patientId) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('reassurances')
        .snapshots()
        .map((snap) {
          final map = <int, List<ReassuranceData>>{};
          for (final d in snap.docs) {
            final data = d.data();
            final idx = (data['situationIndex'] as int?) ?? 0;
            map.putIfAbsent(idx, () => []);
            map[idx]!.add(ReassuranceData(
              headline: data['headline'] ?? '',
              subtext: data['subtext'] ?? '',
              hasRecording: data['hasRecording'] ?? false,
              recordingPath: data['recordingUrl'],
              mediaPath: data['mediaUrl'],
              isVideo: data['isVideo'] ?? false,
            ));
          }
          return map;
        });
  }

  /// Live stream of last sent reassurance for a patient.
  static Stream<ReassuranceData?> lastReassuranceStream(String patientId) {
    return _db.collection('patients').doc(patientId).snapshots().map((snap) {
      final data = snap.data();
      final lastReassurance = data?['lastReassurance'];
      if (lastReassurance == null) return null;
      return ReassuranceData(
        headline: lastReassurance['headline'] ?? '',
        subtext: lastReassurance['subtext'] ?? '',
        hasRecording: false,
        recordingPath: null,
        mediaPath: null,
        isVideo: false,
      );
    });
  }

  /// Live stream of threshold alerts (from /notifications) for a caregiver's patients.
  static Stream<List<PendingAlert>> caregiverAlertsStream(List<String> patientIds) {
    if (patientIds.isEmpty) return Stream.value([]);
    // Firestore 'whereIn' supports up to 30 items
    final ids = patientIds.take(30).toList();
    return _db
        .collection('notifications')
        .where('patientId', whereIn: ids)
        .where('seen', isEqualTo: false)
        .orderBy('firedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return PendingAlert(
                action: data['action'] ?? '',
                count: (data['threshold'] as num?)?.toInt() ?? 0,
                firedAt: (data['firedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                firestoreId: d.id,
                patientId: data['patientId'] ?? '',
                patientName: data['patientName'] ?? '',
              );
            }).toList());
  }

  static Future<void> markAlertSeen(String firestoreId) async {
    await _db.collection('notifications').doc(firestoreId).update({'seen': true});
  }

  // ── Storage ─────────────────────────────────────────────────────────────────

  static Future<String> _uploadFile(String localPath, String storagePath) async {
    // Already a remote URL — nothing to upload.
    if (localPath.startsWith('http')) return localPath;
    final file = File(localPath);
    if (!await file.exists()) throw Exception('File not found: $localPath');
    final ref = _storage.ref(storagePath);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ── Notifications ───────────────────────────────────────────────────────────

  static Future<void> _requestNotificationPermission(String uid) async {
    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await _messaging.getToken();
        if (token != null) {
          await _db.collection('users').doc(uid).update({'fcmToken': token});
        }
      }
    } catch (_) {
      // FCM tokens are unavailable on simulators — silently ignore.
    }
  }

  static Future<void> _sendThresholdNotification(
    String patientId,
    String action,
    int threshold,
  ) async {
    // Store a notification document — in production you'd trigger a
    // Cloud Function to send the FCM push. For the prototype this
    // record is visible to the caregiver via the activity screen.
    final patient = AppState.patients.firstWhere(
      (p) => p.id == patientId,
      orElse: () => PatientProfile(id: patientId, name: 'Patient'),
    );
    await _db.collection('notifications').add({
      'patientId': patientId,
      'patientName': patient.name,
      'action': action,
      'threshold': threshold,
      'firedAt': FieldValue.serverTimestamp(),
      'seen': false,
    });
  }
}
