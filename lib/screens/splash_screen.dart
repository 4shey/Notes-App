import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_notes_app/screens/bottom_navbar.dart';

class SplashIconScreen extends StatefulWidget {
  const SplashIconScreen({super.key});

  @override
  State<SplashIconScreen> createState() => _SplashIconScreenState();
}

class _SplashIconScreenState extends State<SplashIconScreen> {
  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(seconds: 5));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BottomNavbar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EEE2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/splash.json',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
