import 'package:flutter/material.dart';
import 'package:meditrack/splashscreen/SplashScreen.dart' show SplashScreen;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('isDark') ?? false;
  String lang = prefs.getString('lang') ?? 'en'; // 🔥 language load

  runApp(MyApp(isDark, lang));
}

class MyApp extends StatefulWidget {
  final bool isDark;
  final String lang; // 🔥 add

  const MyApp(this.isDark, this.lang, {super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;
  Locale _locale = const Locale('en'); // 🔥 language state

  bool get isDark => _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _locale = Locale(widget.lang); // 🔥 override হবে
  }

  // 🔥 THEME CHANGE
  void changeTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);

    setState(() {
      _isDark = value;
    });
  }

  // 🔥 LANGUAGE CHANGE
  void changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);

    setState(() {
      _locale = Locale(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 LANGUAGE APPLY
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
      ],

      // 🔥 THEME
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
        ),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2F9E5B),
          onPrimary: Colors.white,
          secondary: Color(0xFF2F9E5B),
          onSecondary: Colors.white,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
          background: Color(0xFF121212),
          onBackground: Colors.white,
          error: Colors.red,
          onError: Colors.white,
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.green),
          bodySmall: TextStyle(color: Colors.white70),
        ),
      ),

      home: SplashScreen(),
    );
  }
}