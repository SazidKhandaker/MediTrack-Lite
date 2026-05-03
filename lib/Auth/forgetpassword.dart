import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final emailController = TextEditingController();

  void showSnack(String msg, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> resetPassword() async {
    final lang = Localizations.localeOf(context).languageCode;

    String email = emailController.text.trim();

    if (email.isEmpty) {
      showSnack(
        lang == "bn"
            ? "ইমেইল দিন"
            : "Enter your email",
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showSnack(
        lang == "bn"
            ? "পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে 📩"
            : "Password reset link sent 📩",
        color: Colors.green,
      );

    } on FirebaseAuthException catch (e) {

      if (e.code == 'user-not-found') {
        showSnack(
          lang == "bn"
              ? "এই ইমেইলে কোনো অ্যাকাউন্ট নেই"
              : "No user found with this email",
        );
      } else if (e.code == 'invalid-email') {
        showSnack(
          lang == "bn"
              ? "সঠিক ইমেইল দিন"
              : "Enter a valid email",
        );
      } else {
        showSnack(
          lang == "bn"
              ? "কিছু ভুল হয়েছে"
              : "Something went wrong",
        );
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang == "bn" ? "পাসওয়ার্ড ভুলে গেছেন" : "Forgot Password",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 40),

            Icon(Icons.lock_reset, size: 80, color: Colors.green),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: lang == "bn" ? "ইমেইল লিখুন" : "Enter your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: resetPassword,
              child: Text(
                lang == "bn"
                    ? "রিসেট লিংক পাঠান"
                    : "Send Reset Link",
              ),
            ),
          ],
        ),
      ),
    );
  }
}