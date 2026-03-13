import 'package:flutter/material.dart';
import 'setup_name_screen.dart';

class SetupEmailScreen extends StatefulWidget {
	const SetupEmailScreen({super.key});

	@override
	State<SetupEmailScreen> createState() => _SetupEmailScreenState();
}

class _SetupEmailScreenState extends State<SetupEmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isNextEnabled {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordsMatch;
  }

  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text;

  bool get _showPasswordMismatch {
    return _confirmPasswordController.text.isNotEmpty && !_passwordsMatch;
  }

  void _next() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetupNameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              const Spacer(flex: 1),
              const Center(
                child: Text(
                  'Create an account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Enter your details below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black45),
                ),
              ),
              const SizedBox(height: 20),
              _label('Email'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('example@mail.com'),
              ),
              const SizedBox(height: 10),
              _label('Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('••••••••').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black45,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _label('Password again'),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                autocorrect: false,
                onSubmitted: (_) {
                  if (_isNextEnabled) {
                    _next();
                  }
                },
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('••••••••').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black45,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 20,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedOpacity(
                    opacity: _showPasswordMismatch ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Text(
                      'Passwords do not match.',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isNextEnabled ? _next : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }
}
