import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/users_storage.dart';
import 'package:flutter_notes_app/provider/note_provider.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/provider/todo_provider.dart';
import 'package:flutter_notes_app/provider/users_provider.dart';
import 'package:flutter_notes_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'theme/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userStorage = UserStorage();
  final currentUser = await userStorage.loadUser();

  runApp(
    MultiProvider(
      providers: [
        Provider<UserStorage>.value(value: userStorage),
        ChangeNotifierProvider<EditProfileProvider>(
          create: (_) => EditProfileProvider()..loadCurrentUser(),
        ),
        ChangeNotifierProvider<ToDoProvider>(
          create: (_) =>
              ToDoProvider(userId: currentUser?.id ?? '')..loadTodos(),
        ),
        ChangeNotifierProvider<NoteProvider>(
          create: (_) =>
              NoteProvider(userId: currentUser?.id ?? '')..loadNotes(),
        ),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes & ToDo App',
      home: const SplashIconScreen(),
    );
  }
}
