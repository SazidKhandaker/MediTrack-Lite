import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../homepage.dart' show Homepage, HomePage;

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
    nameController.dispose(); // 🔥 FIX
    super.dispose();
  }

  void showSnack(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
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
        showSnack("Login successful ✅", color: Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }

    } on FirebaseAuthException catch (e) {
      print("ERROR CODE: ${e.code}"); // 🔥 debug

      if (e.code == 'user-not-found') {
        showSnack("User not found ❌");
      } else if (e.code == 'wrong-password') {
        showSnack("Wrong password ❌");
      } else if (e.code == 'invalid-email') {
        showSnack("Invalid email ❌");
      } else {
        showSnack(e.message ?? "Login failed");
      }
    } catch (e) {
      print("UNKNOWN ERROR: $e"); // 🔥 debug
      showSnack("Something went wrong ❌");
    }
  }

  // 🆕 SIGNUP + NAME SAVE
  Future<void> validateAndSignup() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showSnack("All fields required");
      return;
    }

    if (!isChecked) {
      showSnack("Please accept terms");
      return;
    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);

      showSnack("Signup successful ✅", color: Colors.green);

      // 🔥 IMPORTANT
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showSnack("Email already used");
      } else if (e.code == 'weak-password') {
        showSnack("Weak password");
      } else {
        showSnack(e.message ?? "Signup error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      bottomNavigationBar: Container(
        height: 100,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F4C5C), Color(0xFF1B6B73)],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              left: 20,
              bottom: 50,
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            Positioned(
              bottom: 65,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (_tabController.index == 0) {
                    validateAndLogin();
                  } else {
                    validateAndSignup();
                  }
                },
                child: Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Color(0xFFD4AF7A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      )
                    ],
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
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: "Log In"),
                  Tab(text: "Sign Up"),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLogin(),
                    _buildSignup(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 LOGIN UI
  Widget _buildLogin() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.person, color: Colors.white, size: 60),
          const SizedBox(height: 20),

          _textField("Email", controller: emailController),
          const SizedBox(height: 15),
          _textField("Password",
              isPassword: true, controller: passwordController),

          const SizedBox(height: 20),

          _socialButton(
            text: "Continue with Google",
            bgColor: Colors.white,
            textColor: Colors.black,
            icon: Icons.g_mobiledata,
          ),
          _socialButton(
            text: "Continue with Facebook",
            bgColor: Color(0xFF1877F2),
            textColor: Colors.white,
            icon: Icons.facebook,
          ),
        ],
      ),
    );
  }

  // 🔹 SIGNUP UI
  Widget _buildSignup() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8,left: 15,right: 15),
      child: Column(
        children: [
          const Icon(Icons.person_add, color: Colors.white, size: 60),
          const SizedBox(height: 8),

          // 🔥 FIXED
          _textField("Name", controller: nameController),

          const SizedBox(height: 8),
          _textField("Email", controller: emailController),

          const SizedBox(height: 8),
          _textField("Password",
              isPassword: true, controller: passwordController),

          const SizedBox(height: 8),

          _socialButton(
            text: "Sign up with Google",
            bgColor: Colors.white,
            textColor: Colors.black,
            icon: Icons.g_mobiledata,
          ),
          _socialButton(
            text: "Sign up with Facebook",
            bgColor: Color(0xFF1877F2),
            textColor: Colors.white,
            icon: Icons.facebook,
          ),

          Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
              ),
              const Text("I agree to Terms",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required String text,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        showSnack("$text clicked", color: Colors.blue);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String hint,
      {bool isPassword = false, TextEditingController? controller}) {
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