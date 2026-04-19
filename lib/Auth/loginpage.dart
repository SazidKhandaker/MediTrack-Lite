import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isChecked = false;

  // 🔥 Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
    super.dispose();
  }

  // 🔥 Snackbar function
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

  // 🔥 Validation
  void validateAndLogin() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnack("Required Field are empty");
      return;
    }

    if (!email.contains("@gmail.com") && !email.contains("@yahoo.com")) {
      showSnack("Invalid EMail");
      return;
    }

    showSnack("Login successful ✅", color: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      // 🔻 Bottom bar
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
            Positioned(
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
                  validateAndLogin();
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
                  child: Icon(Icons.arrow_forward),
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

  // 🔹 Login UI
  Widget _buildLogin() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person, color: Colors.white, size: 60),
            const SizedBox(height: 10),

            const Text(
              "Log In to Account",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 30),

            _textField("Email", controller: emailController),
            const SizedBox(height: 15),
            _textField("Password",
                isPassword: true, controller: passwordController),

            const SizedBox(height: 20),

            _socialButton("Log in with Google"),
            _socialButton("Log in with Facebook"),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 🔹 Signup UI
  Widget _buildSignup() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person_add, color: Colors.white, size: 60),
            const SizedBox(height: 10),

            const Text(
              "Create an Account",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 30),

            _textField("Email", controller: emailController),
            const SizedBox(height: 15),
            _textField("Password",
                isPassword: true, controller: passwordController),

            const SizedBox(height: 20),

            _socialButton("Sign up with Google"),
            _socialButton("Sign up with Facebook"),

            const SizedBox(height: 20),

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

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 🔹 TextField
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

  // 🔹 Social Button
  Widget _socialButton(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}