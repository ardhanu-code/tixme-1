import 'package:flutter/material.dart';
import 'package:tixme/authentication/register_page.dart';
import 'package:tixme/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TixMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
      routes: {'/register': (context) => const RegisterPage()},
    );
  }
}
