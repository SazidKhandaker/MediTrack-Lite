import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount, GoogleSignInAuthentication, GoogleSignIn;
import 'package:meditrack/Auth/forgetpassword.dart' show ForgotPasswordPage;
import '../homepage.dart' show HomePage;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {

  late TabController _tabController;

  // 🔥 animation
  late AnimationController _btnController;
  late Animation<double> _scaleAnim;

  bool isChecked = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnim = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _btnController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void showSnack(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
  Future<void> signInWithGoogle() async {
    final lang = Localizations.localeOf(context).languageCode;

    try {
      print("START GOOGLE LOGIN");

      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser =
      await googleSignIn.signIn();

      if (googleUser == null) {
        print("USER CANCELLED");
        return;
      }

      print("USER SELECTED: ${googleUser.email}");

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      showSnack(
        lang == "bn"
            ? "গুগল লগইন সফল ✅"
            : "Google login successful ✅",
        color: Colors.green,
      );

    } catch (e) {
      print("GOOGLE ERROR: $e");

      showSnack(
        lang == "bn"
            ? "গুগল লগইন ব্যর্থ ❌"
            : "Google login failed ❌",
      );
    }
  }
  Future<void> validateAndLogin() async {
    final lang = Localizations.localeOf(context).languageCode;

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnack(
        lang == "bn"
            ? "সব ঘর পূরণ করুন"
            : "Required fields are empty",
      );
      return;
    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await user.reload();

      if (!user.emailVerified) {
        showSnack(
          lang == "bn"
              ? "প্রথমে ইমেইল ভেরিফাই করুন 📩"
              : "Please verify your email first 📩",
        );

        await FirebaseAuth.instance.signOut();
        return;
      }
      showSnack(
        lang == "bn"
            ? "লগইন সফল হয়েছে ✅"
            : "Login Successful ✅",
        color: Colors.green,
      );

// 🔥 delay 1 second
      await Future.delayed(const Duration(seconds: 1));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

    } on FirebaseAuthException catch (e) {

      print("LOGIN ERROR: ${e.code}");

      if (e.code == 'user-not-found') {
        showSnack(
          lang == "bn"
              ? "এই ইমেইলে কোনো অ্যাকাউন্ট নেই"
              : "No account found with this email",
        );

      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        showSnack(
          lang == "bn"
              ? "ইমেইল বা পাসওয়ার্ড ভুল"
              : "Email or password is incorrect",
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
              ? "লগইন ব্যর্থ ❌"
              : "Login Failed ❌",
        );
      }

    } catch (e) {
      showSnack(e.toString());
    }
  }

  Future<void> validateAndSignup() async {
    final lang = Localizations.localeOf(context).languageCode;

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showSnack(
        lang == "bn"
            ? "সব ঘর পূরণ করুন"
            : "All fields required",
      );
      return;
    }

    if (!isChecked) {
      showSnack(
        lang == "bn"
            ? "শর্তাবলী গ্রহণ করুন"
            : "Accept terms",
      );
      return;
    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);

      // 🔥 EMAIL VERIFICATION
      await userCredential.user!.sendEmailVerification();

      showSnack(
        lang == "bn"
            ? "ভেরিফিকেশন ইমেইল পাঠানো হয়েছে 📩"
            : "Verification email sent 📩",
        color: Colors.green,
      );

      await FirebaseAuth.instance.signOut();

    }

   on FirebaseAuthException catch (e) {
  if (e.code == 'email-already-in-use') {
  showSnack(
  lang == "bn"
  ? "এই ইমেইল দিয়ে ইতিমধ্যে অ্যাকাউন্ট আছে"
      : "This email already has an account",
  );
  } else if (e.code == 'weak-password') {
  showSnack(
  lang == "bn"
  ? "পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে"
      : "Password should be at least 6 characters",
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
  ? "সাইন আপ ব্যর্থ ❌"
      : "Signup Failed ❌",
  );
  }
  } catch (e) {
  showSnack(e.toString());
  }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        // 🔥 FLOATING BUTTON BAR
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.09,
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
                bottom: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    lang == "bn"
                        ? "পাসওয়ার্ড ভুলে গেছেন?"
                        : "Forgot Password?",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              // 🔥 ANIMATED FLOAT BUTTON
              Positioned(
                right: 20,
                top: -30,
                child: GestureDetector(
                  onTapDown: (_) => _btnController.forward(),
                  onTapUp: (_) => _btnController.reverse(),
                  onTapCancel: () => _btnController.reverse(),
                  onTap: () {
                    if (_tabController.index == 0) {
                      validateAndLogin();
                    } else {
                      validateAndSignup();
                    }
                  },
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF7A),
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
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2F9E5B), Color(0xFF2E8B57)],
              ),
            ),
            child: Column(
              children: [

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

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

  Widget _buildLogin(String lang) {
    return _formLayout([
      const Icon(Icons.person, size: 60, color: Colors.white),

      _textField("Email", emailController),
      _textField("Password", passwordController, isPassword: true),

      _googleBtn(lang),
      _fbBtn(lang),
    ]);
  }

  Widget _buildSignup(String lang) {
    return _formLayout([
      const Icon(Icons.person_add, size: 60, color: Colors.white),

      _textField("Name", nameController),
      _textField("Email", emailController),
      _textField("Password", passwordController, isPassword: true),

      _googleBtn(lang),
      _fbBtn(lang),

      Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (v) => setState(() => isChecked = v!),
          ),
          const Text("I agree to Terms",
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    ]);
  }

  Widget _formLayout(List<Widget> children) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        children: children
            .map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: e,
        ))
            .toList(),
      ),
    );
  }

  Widget _googleBtn(String lang) {
    return GestureDetector(
      onTap: signInWithGoogle, // 🔥 add this
      child: _socialButton(
        text: lang == "bn"
            ? "গুগল দিয়ে চালান"
            : "Continue with Google",
        bgColor: Colors.white,
        textColor: Colors.black,
        icon: const Text(
          "G",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _fbBtn(String lang) {
    return _socialButton(
      text: lang == "bn"
          ? "ফেসবুক দিয়ে চালান"
          : "Continue with Facebook",
      bgColor: const Color(0xFF1877F2),
      textColor: Colors.white,
      icon: const Icon(Icons.facebook, color: Colors.white),
    );
  }

  Widget _socialButton({
    required String text,
    required Color bgColor,
    required Color textColor,
    required Widget icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Text(text,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold)),
        ],
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