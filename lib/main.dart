import 'package:flutter/material.dart';
import 'package:flutter_notes_app/screens/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Notes',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8EEE2),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFD9614C)),
        useMaterial3: true,
      ),
      home: SplashIconScreen(),
    );
  }
}
