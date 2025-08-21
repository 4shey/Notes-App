import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/note_provider.dart';
import 'package:flutter_notes_app/provider/todo_provider.dart';
import 'package:flutter_notes_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ToDoProvider()..loadTodos()),
        ChangeNotifierProvider(create: (_) => NoteProvider()..loadNotes()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashIconScreen(),
    );
  }
}