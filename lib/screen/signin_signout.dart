import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
//import 'package:final_pro/screen/verify_code.dart'; // Import the VerifyCodeScreen
// ignore: unused_import
import 'package:final_pro/screen/HomePage.dart'; // Import the HomePage screen
//import 'package:final_pro/screen/completprofile_screen.dart';

const String lottieAnimationUrl =
    'https://lottie.host/fd76a9b4-fa20-4377-a559-4c1969e26b22/LKsTwFp6NW.json';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park Spot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthScreenSignIn(),
    );
  }
}

class AuthScreenSignIn extends StatelessWidget {
  const AuthScreenSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA), Color(0xFF84CDEE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Lottie.network(
                    lottieAnimationUrl,
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Park Spot',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Hello, Sign In...',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _tabButton(context, "Sign In", true),
                      _tabButton(context, "Sign Up", false),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSignInForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(BuildContext context, String text, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (text == "Sign Up") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreenSignUp()),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Column(
      children: [
        _inputField(label: "Phone or Gmail", controller: emailController),
        _inputField(
          label: "Password",
          controller: passwordController,
          obscure: true,
        ),
        const SizedBox(height: 20),
        _gradientButton(
          "Sign In",
          onTap: () async {
            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              );
              // Navigate to home page after signing in
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } on FirebaseAuthException catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? "Sign In Failed")),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreenSignUp(),
                ),
              );
            },
            child: const Text(
              "Don't have an account? Sign Up",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          // ignore: deprecated_member_use
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _gradientButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF6B9DD7), Color(0xFFB0DAFF)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthScreenSignUp extends StatelessWidget {
  const AuthScreenSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Lottie.network(
                    lottieAnimationUrl,
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Park Spot',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Create Your Account',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _tabButton(context, "Sign In", false),
                      _tabButton(context, "Sign Up", true),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSignUpForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(BuildContext context, String text, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (text == "Sign In") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreenSignIn()),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputField(label: "Full Name", controller: fullNameController),
        _inputField(label: "Email", controller: emailController),
        _inputField(label: "Phone Number", controller: phoneController),
        _inputField(
          label: "Password",
          controller: passwordController,
          obscure: true,
        ),
        _inputField(
          label: "Confirm Password",
          controller: confirmPasswordController,
          obscure: true,
        ),
        const SizedBox(height: 20),
        _gradientButton(
          "Sign Up with Email",
          onTap: () async {
            if (passwordController.text != confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Passwords do not match")),
              );
              return;
            }
            if (emailController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter your email")),
              );
              return;
            }
            try {
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              );
              await FirebaseAuth.instance.currentUser!.sendEmailVerification();
              Navigator.push(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            } on FirebaseAuthException catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? "Sign Up Failed")),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreenSignIn(),
                ),
              );
            },
            child: const Text(
              "Already have an account? Sign In",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          // ignore: deprecated_member_use
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _gradientButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF6B9DD7), Color(0xFFB0DAFF)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
