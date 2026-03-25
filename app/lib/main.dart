// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'app_state.dart';
import 'screens/welcome_screen.dart';
import 'screens/caregiver_home_screen.dart';
import 'screens/patient_home_screen.dart';
import 'screens/patient_activity_screen.dart';
import 'services/widget_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
final settingsNotifier = ValueNotifier<int>(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await WidgetService.init();
  AppSettings.loadForCurrentAccount();
  runApp(const UnscriptedApp());
}

class UnscriptedApp extends StatelessWidget {
  const UnscriptedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        AppSettings.themeMode = mode;
        return ValueListenableBuilder<int>(
          valueListenable: settingsNotifier,
          builder: (context, settingsCount, settingsChild) {
            final reducedMotion = AppSettings.reducedMotion;
            return MaterialApp(
              title: '[un]scripted',
              debugShowCheckedModeBanner: false,
              theme: reducedMotion
                  ? AppTheme.light().copyWith(
                      pageTransitionsTheme: PageTransitionsTheme(
                        builders: {
                          for (final platform in TargetPlatform.values)
                            platform: _NoAnimationPageTransitionsBuilder(),
                        },
                      ),
                    )
                  : AppTheme.light(),
              darkTheme: reducedMotion
                  ? AppTheme.dark().copyWith(
                      pageTransitionsTheme: PageTransitionsTheme(
                        builders: {
                          for (final platform in TargetPlatform.values)
                            platform: _NoAnimationPageTransitionsBuilder(),
                        },
                      ),
                    )
                  : AppTheme.dark(),
              themeMode: mode,
              home: const WelcomeScreen(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(AppSettings.textScale),
                  ),
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppSettings.reducedMotion) return child;
    return const FadeUpwardsPageTransitionsBuilder()
        .buildTransitions(route, context, animation, secondaryAnimation, child);
  }
}

// ── Helper: wraps any screen in the full app shell so previews work ──────────
Widget _preview(Widget screen) {
  // Seed some demo state so the preview has something to show
  if (AppState.patients.isEmpty) {
    AppState.patients.add(
      PatientProfile(id: AppState.defaultPatientId, name: 'Margaret'),
    );
  }
  AppState.loggedInName = 'Alex';
  AppState.loggedInRole = 'caregiver';

  return ValueListenableBuilder<ThemeMode>(
    valueListenable: themeNotifier,
    builder: (context, mode, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      home: screen,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(AppSettings.textScale),
        ),
        child: child!,
      ),
    ),
  );
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'Welcome Screen', size: Size(400, 750))
Widget welcomePreview() => const UnscriptedApp();

@Preview(name: 'Caregiver Home', size: Size(400, 750))
Widget caregiverHomePreview() => _preview(const CaregiverHomeScreen());

@Preview(name: 'Patient Home', size: Size(400, 750))
Widget patientHomePreview() => _preview(const PatientHomeScreen());

@Preview(name: 'Patient Activity', size: Size(400, 750))
Widget patientActivityPreview() => _preview(
      PatientActivityScreen(patient: AppState.patients.first),
    );