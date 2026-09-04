import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final token = prefs.getString('auth_token');

    if (!onboardingDone) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    } else if (token == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🐱', style: TextStyle(fontSize: 80)),
            SizedBox(height: 20),
            Text('مشمش', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B))),
            SizedBox(height: 10),
            Text('اعثر على قطتك المفضلة', style: TextStyle(fontSize: 16, color: Color(0xFF636E72))),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Color(0xFFFF6B6B)),
          ],
        ),
      ),
    );
  }
}
