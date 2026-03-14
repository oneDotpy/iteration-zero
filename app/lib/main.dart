// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'theme/app_theme.dart';
import 'app_state.dart';
import 'screens/welcome_screen.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
/// Increment this whenever a setting (other than theme) changes to force a
/// full app rebuild so MediaQuery / AppColors re-reads AppSettings values.
final settingsNotifier = ValueNotifier<int>(0);

void main() {
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
            return MaterialApp(
              title: '[un]scripted',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
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

// Preview for the welcome screen
@Preview(
  name: 'Welcome Screen',
  size: Size(400, 750),
)
Widget welcomePreview() => const UnscriptedApp();
