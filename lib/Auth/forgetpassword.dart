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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            lang == "bn" ? "পাসওয়ার্ড ভুলে গেছেন" : "Forgot Password",
          ),
        ),
      
        body: Padding(
          padding: const EdgeInsets.all(20),
          child:SingleChildScrollView(child:  Column(
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
      
          GestureDetector(
            onTap: resetPassword,
            child: Container(
              transform: Matrix4.identity()..scale(0.97),
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.018,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2F9E5B),
                    Color(0xFF1B6B73),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                    lang == "bn"
                        ? "রিসেট লিংক পাঠান"
                        : "Send Reset Link",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                ),
              ),
            ),
          )],
          ),
        ),
      ),
    ));

  }


}