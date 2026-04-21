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
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
      ),
      home: SplashScreen(),
    );
  }
}