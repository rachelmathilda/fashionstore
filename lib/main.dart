import 'package:flutter/material.dart';
import 'package:fashionstore/pages/start/splash_screen.dart';
import 'package:fashionstore/pages/start/login.dart';
import 'package:fashionstore/pages/start/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fashionapp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFEAEDFB),
        primaryColor: const Color(0xFF898AC4),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF898AC4),
          secondary: Color(0xFFC0C9EE),
          surface: Color(0xFFEAEDFB),
          onPrimary: Colors.white,
          onSecondary: Color(0xFF898AC4),
          onSurface: Color(0xFF898AC4),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEAEDFB),
          foregroundColor: Color(0xFF898AC4),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF898AC4)),
          bodyMedium: TextStyle(color: Color(0xFF898AC4)),
          bodySmall: TextStyle(color: Color(0xFFC0C9EE)),
          titleLarge: TextStyle(
            color: Color(0xFF898AC4),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF898AC4)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF898AC4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF898AC4), width: 2),
            foregroundColor: const Color(0xFF898AC4),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
      },
    );
  }
}
