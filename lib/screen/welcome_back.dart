// ignore_for_file: file_names

import 'package:final_pro/screen/signin_signout.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// REMOVED: import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:final_pro/screen/HomePage.dart';

void main() {
  runApp(const ParkSpotApp());
}

class ParkSpotApp extends StatelessWidget {
  const ParkSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park Spot',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WelcomeBackScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  // REMOVED: final GoogleSignIn _googleSignIn = GoogleSignIn();
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // REMOVED: _signInWithGoogle method

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA), Color(0xFF84CDEE)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.network(
                  'https://lottie.host/7e5ed1a5-a6b6-4d52-a76a-f8f52a27472a/kiW6KxhfuG.json',
                  width: size.width * 0.8,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreenSignIn(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreenSignUp(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 154, 191, 221),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Login with Social Media',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.facebook, color: Colors.black),
                      onPressed: () {
                        debugPrint("Facebook Sign-In not implemented.");
                      },
                    ),
                    // REMOVED: Google Sign-In button
                    IconButton(
                      icon: const Icon(Icons.apple, color: Colors.black),
                      onPressed: () {
                        debugPrint("Apple Sign-In not implemented.");
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.g_mobiledata, color: Colors.black),
                      onPressed: () {
                        debugPrint("Google Sign-In not implemented.");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// REMOVED: GoogleSignIn
