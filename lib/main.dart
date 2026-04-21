import 'package:flutter/material.dart';
import 'package:meditrack/splashscreen/SplashScreen.dart' show SplashScreen;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('isDark') ?? false;

  runApp(MyApp(isDark));
}

class MyApp extends StatefulWidget {
  final bool isDark;
  const MyApp(this.isDark, {super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   bool _isDark=false;

  bool get isDark => _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  void changeTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);

    setState(() {
      _isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme:  ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
        ),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2F9E5B), // green accent
          onPrimary: Colors.white,

          secondary: Color(0xFF2F9E5B),
          onSecondary: Colors.white,

          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white, // 🔥 main text color

          background: Color(0xFF121212),
          onBackground: Colors.white, // 🔥 fix header issue

          error: Colors.red,
          onError: Colors.white,
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.green), // 🌿 your idea
          bodySmall: TextStyle(color: Colors.white70),
        ),
      ),
      home: SplashScreen(),
    );
  }
}