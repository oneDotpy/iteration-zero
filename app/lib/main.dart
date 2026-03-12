import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const ConnectionApp());
}

class ConnectionApp extends StatelessWidget {
  const ConnectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Preview for the welcome screen
@Preview(
  name: 'Welcome Screen',
  size: Size(300, 550),
)
Widget welcomePreview() => const ConnectionApp();
