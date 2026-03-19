// lib/services/widget_service.dart
import 'package:home_widget/home_widget.dart';
import '../app_state.dart';

/// App Group ID — must match the one configured in Xcode for both
/// the Runner target and the ConnectionWidget extension target.
const _appGroupId = 'group.connection.app';

class WidgetService {
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Call after any patient button tap to refresh the caregiver widget.
  static Future<void> updateCaregiverWidget() async {
    final stats = AppState.getUsageFor(AppState.defaultPatientId);
    final patient = AppState.patients.isNotEmpty ? AppState.patients.first : null;

    await HomeWidget.saveWidgetData('cg_patient_name', patient?.name ?? 'Your care recipient');
    await HomeWidget.saveWidgetData('cg_feel_unsure', stats.countToday(kEventFeelUnsure));
    await HomeWidget.saveWidgetData('cg_hear_voice', stats.countToday(kEventHearVoice));
    await HomeWidget.saveWidgetData('cg_breather', stats.countToday(kEventBreather));
    await HomeWidget.saveWidgetData('cg_app_opens', stats.countToday(kEventAppOpen));
    await HomeWidget.saveWidgetData('cg_last_updated', DateTime.now().toIso8601String());

    await HomeWidget.updateWidget(
      iOSName: 'CaregiverWidget',
      androidName: 'CaregiverWidgetProvider',
    );
  }

  /// Call after a new reassurance message is saved to refresh the patient widget.
  static Future<void> updatePatientWidget() async {
    final messages = AppState.getMessagesFor(AppState.defaultPatientId);
    // Find the most recently added message with a recording
    ReassuranceData? latest;
    for (final list in messages.values) {
      for (final msg in list) {
        if (msg.hasRecording) latest = msg;
      }
    }

    final caregiver = AppState.loggedInName.isNotEmpty
        ? AppState.loggedInName
        : 'Your caregiver';

    await HomeWidget.saveWidgetData('pt_headline', latest?.headline ?? 'You are safe.');
    await HomeWidget.saveWidgetData('pt_subtext', latest?.subtext ?? 'Take a slow breath.');
    await HomeWidget.saveWidgetData('pt_caregiver_name', caregiver);
    await HomeWidget.saveWidgetData('pt_has_message', latest != null);

    await HomeWidget.updateWidget(
      iOSName: 'PatientWidget',
      androidName: 'PatientWidgetProvider',
    );
  }
}
