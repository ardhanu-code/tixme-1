import 'package:flutter/material.dart';
import 'package:tixme/screens/home_screen.dart';
import 'package:tixme/authentication/login_page.dart';
import 'package:tixme/services/session_service.dart'; // untuk AuthPreferences
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthPreferences.getLoginStatus();
    final token = await AuthPreferences.getToken();

    await Future.delayed(const Duration(seconds: 2)); // efek loading

    if (isLoggedIn && token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation, color: Colors.white, size: 80),
            const SizedBox(height: 20),
            Text(
              'TixMe',
              style: GoogleFonts.lexend(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
