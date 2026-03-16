// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_text_field.dart';
import '../widgets/primary_cta_button.dart';
import '../widgets/primary_icon_button.dart';
import 'caregiver_home_screen.dart';
import 'patient_home_screen.dart';
import 'create_account_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_loading) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final role = AppState.login(
        _emailController.text,
        _passwordController.text,
      );
      setState(() => _loading = false);

      if (role == null) {
        setState(() => _errorMessage = 'Incorrect email or password. Please try again.');
        return;
      }

      // Navigate first, then update theme/settings to avoid visual change on login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'caregiver'
              ? const CaregiverHomeScreen()
              : const PatientHomeScreen(),
        ),
        (route) => false,
      );

      // Use a post-frame callback to update ALL settings after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSettings.loadForCurrentAccount();
        themeNotifier.value = AppSettings.themeMode;
        settingsNotifier.value++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.tealLight,
      appBar: AppBar(
        backgroundColor: colors.tealLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: colors.teal,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Title
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: colors.textHigh,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Sign in to continue.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textMed,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Email field
              SoftTextField(
                controller: _emailController,
                hint: 'you@example.com',
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                fillColor: colors.background,
                onChanged: (_) {
                  if (_errorMessage.isNotEmpty) setState(() => _errorMessage = '');
                },
              ),

              const SizedBox(height: 18),

              // Password field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textMed,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _login(),
                    style: TextStyle(
                      color: colors.textHigh,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(color: colors.textLow),
                      filled: true,
                      fillColor: colors.background,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colors.textMed,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colors.textMed,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: colors.teal, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Sign In button
              _loading
                  ? Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.teal,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [colors.shadow],
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: colors.textHigh,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  :  Container(
                      width: double.infinity,
                      height: 60,
                      child: PrimaryCtaButton(
                      label: 'Log in',
                      onTap: _login,
                      color: colors.teal,
                      textColor: colors.textHigh,
                      height: 60,
                    ),
                  ),

              const SizedBox(height: 16),

              // Inline error
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.rose.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.rose.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: colors.rose,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.rose,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Don't have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 14, color: colors.textMed),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreateAccountScreen()),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textHigh,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: Text(
                      'Create one',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600, 
                        color: colors.teal),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
