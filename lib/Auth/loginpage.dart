import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../homepage.dart' show HomePage;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  bool isChecked = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void showSnack(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // 🔐 LOGIN
  Future<void> validateAndLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnack("Required Fields are empty");
      return;
    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      showSnack("Login Failed ❌");
    }
  }

  // 🆕 SIGNUP
  Future<void> validateAndSignup() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showSnack("All fields required");
      return;
    }

    if (!isChecked) {
      showSnack("Accept terms");
      return;
    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      showSnack("Signup Failed ❌");
    }
  }

  @override
  Widget build(BuildContext context) {

    final lang = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
      
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.12,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F4C5C), Color(0xFF1B6B73)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 20,
                bottom: 20,
                child: Text(
                  lang == "bn" ? "পাসওয়ার্ড ভুলে গেছেন?" : "Forgot Password?",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: GestureDetector(
                  onTap: () {
                    if (_tabController.index == 0) {
                      validateAndLogin();
                    } else {
                      validateAndSignup();
                    }
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF7A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _tabController.index == 0
                          ? Icons.login
                          : Icons.app_registration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      
        body: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2F9E5B), Color(0xFF2E8B57)],
              ),
            ),
            child: Column(
              children: [
      
                const SizedBox(height: 20),
      
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: lang == "bn" ? "লগইন" : "Log In"),
                    Tab(text: lang == "bn" ? "সাইন আপ" : "Sign Up"),
                  ],
                ),
      
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLogin(lang),
                      _buildSignup(lang),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 LOGIN UI
  Widget _buildLogin(String lang) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [

                const SizedBox(height: 30),

                const Icon(Icons.person, size: 60, color: Colors.white),

                const SizedBox(height: 20),

                _textField(lang == "bn" ? "ইমেইল" : "Email", emailController),

                const SizedBox(height: 15),

                _textField(lang == "bn" ? "পাসওয়ার্ড" : "Password",
                    passwordController,
                    isPassword: true),

                const SizedBox(height: 20),

                _button(lang == "bn"
                    ? "গুগল দিয়ে চালান"
                    : "Continue with Google"),

                _button(lang == "bn"
                    ? "ফেসবুক দিয়ে চালান"
                    : "Continue with Facebook"),

              ],
            ),
          ),
        );
      },
    );
  }

  // 🔹 SIGNUP UI
  Widget _buildSignup(String lang) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [

                const SizedBox(height: 20),

                const Icon(Icons.person_add, size: 60, color: Colors.white),

                const SizedBox(height: 10),

                _textField(lang == "bn" ? "নাম" : "Name", nameController),

                const SizedBox(height: 10),

                _textField(lang == "bn" ? "ইমেইল" : "Email", emailController),

                const SizedBox(height: 10),

                _textField(lang == "bn" ? "পাসওয়ার্ড" : "Password",
                    passwordController,
                    isPassword: true),

                const SizedBox(height: 15),

                _button(lang == "bn"
                    ? "গুগল দিয়ে সাইন আপ"
                    : "Sign up with Google"),

                _button(lang == "bn"
                    ? "ফেসবুক দিয়ে সাইন আপ"
                    : "Sign up with Facebook"),

                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (v) => setState(() => isChecked = v!),
                    ),
                    Text(
                      lang == "bn"
                          ? "আমি শর্তাবলীতে সম্মত"
                          : "I agree to Terms",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _button(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _textField(String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}