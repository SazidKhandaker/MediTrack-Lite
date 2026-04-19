import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }


  @override
  bool isChecked = false;
  Widget build(BuildContext context) {

    return Scaffold(

      // 🔥 Bottom floating area
      bottomNavigationBar: Container(
        height: 100,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F4C5C), Color(0xFF1B6B73)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 🔹 Forgot password text
            Positioned(
              left: 20,
              bottom: 50,
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.white70),
              ),
            ),

            // 🔥 Floating button
            Positioned(
              bottom: 65,
              right: 20,
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
          ],
        ),
      ),

      // 🔹 Main body
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2F9E5B),
              Color(0xFF2E8B57),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔹 Tabs
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

              const SizedBox(height: 20),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLogin(),
                    _buildSignup(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Login UI
  Widget _buildLogin() {
    return Padding(
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

          _textField("Email"),
          const SizedBox(height: 15),
          _textField("Password", isPassword: true),

          const SizedBox(height: 20),

          _socialButton("Log in with Google"),
          _socialButton("Log in with Facebook"),

          const Spacer(),
        ],
      ),
    );
  }

  // 🔹 Signup UI
  Widget _buildSignup() {
    return Padding(
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

          _textField("Email"),
          const SizedBox(height: 15),
          _textField("Password", isPassword: true),

          const SizedBox(height: 20),

          _socialButton("Sign up with Google"),
          _socialButton("Sign up with Facebook"),

          const Spacer(),

          Row(
            children:  [
              Checkbox(value: isChecked, onChanged: (value){
                  setState(() {
                    isChecked = value!;
                  });
              }),

              Text("I agree to Terms",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // 🔹 TextField
  Widget _textField(String hint, {bool isPassword = false}) {
    return TextField(
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