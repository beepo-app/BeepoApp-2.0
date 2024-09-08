import 'package:Beepo/screens/auth/onboarding_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const OnboardingScreen();
          }));
        },
        icon: Image.asset("assets/splash.png"),
      ),
    );
  }
}
