import 'package:flutter/material.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/view/signup_screen.dart';
import 'features/dashboard/view/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: false,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC648B6),
        brightness: Brightness.light,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      darkTheme: appTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
