import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/authentication/login_page.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/screens/home_screen.dart';
import 'package:tixme/services/session_service.dart'; // untuk AuthPreferences

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
    final isLoggedIn = await AuthPreferences.isLoggedIn();
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Image.asset(
                'assets/images/tixme_logo.png',
                height: 200,
                width: 200,
              ),
              Spacer(),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              Spacer(),
              Text('v1.0.0', style: GoogleFonts.lexend(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
