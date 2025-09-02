import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/users_storage.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_notes_app/screens/bottom_navbar.dart';
import 'package:flutter_notes_app/screens/login_screen.dart';
import 'package:provider/provider.dart';

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
    await Future.delayed(const Duration(seconds: 5)); // durasi splash

    final userStorage = UserStorage();
    final isLoggedIn = await userStorage.isUserLoggedIn();

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavbar()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(isDarkMode),
      body: Center(
        child: isDarkMode
            ? Lottie.asset(
                'assets/lottie/splash_dark.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              )
            : Lottie.asset(
                'assets/lottie/splash.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
