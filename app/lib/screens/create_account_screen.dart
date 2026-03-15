// lib/screens/create_account_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/soft_text_field.dart';
import '../widgets/primary_cta_button.dart';
import '../widgets/primary_icon_button.dart';
import 'caregiver_home_screen.dart';
import 'patient_home_screen.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String _role = 'caregiver'; // 'caregiver' or 'patient'
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text.trim();

    final valid = _validateForm(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (!valid) {
      return;
    }

    setState(() => _loading = true);

    final role = AppState.register(
      email: email,
      password: password,
      name: name,
      role: _role,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            role == 'patient' ? const PatientHomeScreen() : const CaregiverHomeScreen(),
      ),
      (route) => false,
    );
  }

  bool _validateForm({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final missingName = name.isEmpty;
    final missingEmail = email.isEmpty;
    final missingPassword = password.isEmpty;
    final missingConfirm = confirmPassword.isEmpty;
    final mismatch = !missingPassword && !missingConfirm && password != confirmPassword;

    setState(() {
      _nameError = missingName ? 'Please enter your name.' : null;
      _emailError = missingEmail ? 'Please enter your email.' : null;
      _passwordError = missingPassword ? 'Please enter a password.' : null;
      if (missingConfirm) {
        _confirmPasswordError = 'Please confirm your password.';
      } else if (mismatch) {
        _confirmPasswordError = 'Passwords do not match.';
      } else {
        _confirmPasswordError = null;
      }
    });

    return !(missingName || missingEmail || missingPassword || missingConfirm || mismatch);
  }

  void _onPasswordInputsChanged() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    setState(() {
      if (_passwordError != null && password.isNotEmpty) {
        _passwordError = null;
      }
      if (_confirmPasswordError != null && confirm.isNotEmpty) {
        _confirmPasswordError = null;
      }

      if (confirm.isNotEmpty && password != confirm) {
        _confirmPasswordError = 'Passwords do not match.';
      }
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
        leading: AppBackButton(
          color: colors.teal,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "Let's get you set up.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colors.textMed,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Role selector (using FilledButton)
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _role == 'caregiver' ? colors.teal : colors.tealLight,
                        foregroundColor: colors.textHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: _role == 'caregiver' ? colors.teal : colors.border,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        elevation: 0,
                      ),
                      onPressed: () => setState(() => _role = 'caregiver'),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: colors.textHigh,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Caregiver',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textHigh,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _role == 'patient' ? colors.teal : colors.tealLight,
                        foregroundColor: colors.textHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: _role == 'patient' ? colors.teal : colors.border,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        elevation: 0,
                      ),
                      onPressed: () => setState(() => _role = 'patient'),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            color: colors.textHigh,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Patient',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textHigh,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Form card
              SoftCard(
                color: colors.tealLight,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoftTextField(
                      controller: _nameController,
                      hint: 'Your name',
                      label: 'Name',
                      errorText: _nameError,
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      fillColor: colors.background,
                      onChanged: (value) {
                        if (_nameError != null && value.trim().isNotEmpty) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    SoftTextField(
                      controller: _emailController,
                      hint: 'you@example.com',
                      label: 'Email',
                      errorText: _emailError,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      fillColor: colors.background,
                      onChanged: (value) {
                        if (_emailError != null && value.trim().isNotEmpty) {
                          setState(() => _emailError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
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
                          onChanged: (_) => _onPasswordInputsChanged(),
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: colors.textHigh,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            errorText: _passwordError,
                            errorStyle: TextStyle(color: colors.rose),
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
                              borderSide: BorderSide(
                                  color: colors.teal, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: colors.rose, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: colors.rose, width: 1.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Confirm password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textMed,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _confirmPasswordController,
                          onChanged: (_) => _onPasswordInputsChanged(),
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: colors.textHigh,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            errorText: _confirmPasswordError,
                            errorStyle: TextStyle(color: colors.rose),
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
                              borderSide: BorderSide(
                                  color: colors.teal, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: colors.rose, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: colors.rose, width: 1.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Create Account button
              _loading
                  ? Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.teal,
                        borderRadius: BorderRadius.circular(16),
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
                  : PrimaryCtaButton(
                      label: 'Create account',
                      onTap: _createAccount,
                      color: colors.teal,
                      textColor: colors.textHigh,
                    ),

              const SizedBox(height: 20),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textMed,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textHigh,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.teal,
                      ),
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
