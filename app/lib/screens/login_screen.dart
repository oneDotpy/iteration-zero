// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_text_field.dart';
import '../widgets/primary_cta_button.dart';
import 'caregiver_home_screen.dart';
import 'patient_home_screen.dart';
import 'create_account_screen.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    setState(() => _loading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final role = AppState.login(
        _emailController.text,
        _passwordController.text,
      );
      setState(() => _loading = false);

      if (role == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email or password.'),
            backgroundColor: Colors.redAccent.shade200,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'caregiver'
              ? const CaregiverHomeScreen()
              : const PatientHomeScreen(),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [colors.shadow],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colors.textHigh,
              size: 18,
            ),
          ),
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
                alignment: Alignment.centerLeft,
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
                alignment: Alignment.centerLeft,
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
                      fillColor: colors.surfaceAlt,
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
                            BorderSide(color: colors.primary, width: 1.5),
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
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : PrimaryCtaButton(
                      label: 'Sign In',
                      onTap: _login,
                      color: colors.primary,
                    ),

              const SizedBox(height: 20),

              // Demo hint
              Text(
                'Demo: caregiver@gmail.com / caregiver',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMed.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
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
                      foregroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: const Text(
                      'Create one',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
