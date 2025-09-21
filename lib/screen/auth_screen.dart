import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:final_pro/screen/verify_code.dart';
import 'package:final_pro/services/auth_service.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignUp = true;
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    try {
      if (isSignUp) {
        // Sign Up flow
        final user = await _authService.signUpWithEmail(
          email,
          password,
          fullName,
        );
        setState(() => _isLoading = false);

        if (user != null) {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (_) => const VerifyCodeScreen(isEmailVerification: true),
            ),
          );
        }
      } else {
        // Sign In flow
        final user = await _authService.signInWithEmail(email, password);
        setState(() => _isLoading = false);

        if (user != null) {
          if (user.emailVerified) {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder:
                    (_) => const VerifyCodeScreen(isEmailVerification: true),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F1F6), Color(0xFF84CDEE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Lottie.network(
                    'https://lottie.host/fd76a9b4-fa20-4377-a559-4c1969e26b22/LKsTwFp6NW.json',
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Park Spot',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(12),
                    isSelected: [isSignUp, !isSignUp],
                    onPressed: (index) => setState(() => isSignUp = index == 0),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Sign Up"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Sign In"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (isSignUp)
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? "Enter your full name"
                                        : null,
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                          validator:
                              (value) =>
                                  value!.contains("@")
                                      ? null
                                      : "Enter a valid email",
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                          ),
                          validator:
                              (value) =>
                                  value!.length < 6 ? "Min 6 characters" : null,
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.blueAccent,
                              ),
                              child: Text(isSignUp ? "Register" : "Login"),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
