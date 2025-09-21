import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:final_pro/screen/completprofile_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String? verificationId; // For phone auth
  final bool isEmailVerification;

  const VerifyCodeScreen({
    super.key,
    this.verificationId,
    required this.isEmailVerification,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;
  bool emailVerified = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEmailVerification) {
      _sendEmailVerification();
    }
  }

  /// Sends the email verification and starts checking
  Future<void> _sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        _checkEmailVerification();
      } catch (e) {
        _showError("Failed to send verification email: $e");
      }
    } else {
      _checkEmailVerification();
    }
  }

  /// Checks if the user's email is verified periodically
  void _checkEmailVerification() async {
    while (!emailVerified) {
      await Future.delayed(const Duration(seconds: 3));
      await _auth.currentUser?.reload();
      if (_auth.currentUser?.emailVerified ?? false) {
        setState(() {
          emailVerified = true;
        });
        _navigateToCompleteProfile();
        break;
      }
    }
  }

  /// Handles phone verification
  Future<void> _verifyPhoneCode() async {
    if (widget.verificationId == null) {
      _showError("Verification ID is missing");
      return;
    }

    setState(() => isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId!,
        smsCode: _codeController.text.trim(),
      );

      await _auth.signInWithCredential(credential);
      _navigateToCompleteProfile();
    } catch (e) {
      _showError("Invalid code or verification failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Navigates to Complete Profile Screen
  void _navigateToCompleteProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
    );
  }

  /// Shows error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  widget.isEmailVerification
                      ? 'assets/email_verify.json'
                      : 'assets/phone_verify.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.isEmailVerification
                      ? "Please verify your email"
                      : "Enter the SMS code sent to your phone",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (!widget.isEmailVerification) ...[
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Verification Code',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _verifyPhoneCode,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Verify Code",
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ],
                if (widget.isEmailVerification) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "A verification email has been sent.\nPlease check your inbox.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
