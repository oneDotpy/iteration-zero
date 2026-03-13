// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'app_state.dart';
import 'screens/welcome_screen.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

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
        return MaterialApp(
          title: '[un]scripted',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
