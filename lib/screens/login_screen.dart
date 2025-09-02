import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notes_app/models/users_storage.dart';
import 'package:flutter_notes_app/provider/note_provider.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/provider/todo_provider.dart';
import 'package:flutter_notes_app/provider/users_provider.dart';
import 'package:flutter_notes_app/screens/bottom_navbar.dart';
import 'package:flutter_notes_app/screens/register_screen.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:flutter_notes_app/widgets/exit_dialog.dart';
import 'package:flutter_notes_app/widgets/input_decoration.dart';
import 'package:flutter_notes_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserStorage _userStorage = UserStorage();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      TopToast.show(
        context,
        "Please enter your email and password",
        type: ToastType.error,
      );
      return;
    }

    final user = await _userStorage.login(email, password);
    if (user != null) {
      // Update provider sesuai user yang login
      final todoProvider = context.read<ToDoProvider>();
      final noteProvider = context.read<NoteProvider>();
      final userProvider = context.read<EditProfileProvider>();

      await todoProvider.setUserIdAndLoad(user.id);
      await noteProvider.setUserIdAndLoad(user.id);
      await userProvider.setUser(user);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavbar()),
      );
    } else {
      TopToast.show(
        context,
        "Invalid email or password",
        type: ToastType.error,
      ); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    return WillPopScope(
      onWillPop: () async {
        bool shouldClose = false;

        await showDialog(
          context: context,
          builder: (context) => ConfirmCloseDialog(
            onConfirm: () {
              shouldClose = true;
              SystemNavigator.pop(); // langsung close app
            },
          ),
        );

        return shouldClose ? false : false;
        // return false karena sudah handle close manual
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(isDarkMode),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontFamily: 'TitanOne',
                      fontSize: 35,
                      color: AppColors.darkgrey(isDarkMode),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let’s continue your notes journey',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightGrey(isDarkMode),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    decoration: inputDecoration(
                      "Email",
                      Icons.email,
                      themeProvider.isDarkMode,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    decoration:
                        inputDecoration(
                          "Password",
                          Icons.lock,
                          themeProvider.isDarkMode,
                        ).copyWith(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12, left: 6),
                            child: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.mainColor(isDarkMode),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: AppColors.mainColor(isDarkMode),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        color: AppColors.white(isDarkMode),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.mainColor(isDarkMode),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
