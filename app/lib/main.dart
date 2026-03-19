// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'theme/app_theme.dart';
import 'app_state.dart';
import 'screens/welcome_screen.dart';
import 'services/widget_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
/// Increment this whenever a setting (other than theme) changes to force a
/// full app rebuild so MediaQuery / AppColors re-reads AppSettings values.
final settingsNotifier = ValueNotifier<int>(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

// Custom PageTransitionsBuilder that disables transitions if reduced motion is enabled.
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
    if (AppSettings.reducedMotion) {
      return child;
    }
    // Use the default Material fade upwards transition for non-reduced motion
    return const FadeUpwardsPageTransitionsBuilder()
        .buildTransitions(route, context, animation, secondaryAnimation, child);
  }
}

// Preview for the welcome screen
@Preview(
  name: 'Welcome Screen',
  size: Size(400, 750),
)
Widget welcomePreview() => const UnscriptedApp();
