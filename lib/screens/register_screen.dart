import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/users.dart';
import 'package:flutter_notes_app/models/users_storage.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/screens/login_screen.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:flutter_notes_app/widgets/input_decoration.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final UserStorage _userStorage = UserStorage();
  final Uuid _uuid = const Uuid();

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields must be filled!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!email.endsWith("@gmail.com")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email must end with @gmail.com"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password and Confirm Password do not match!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = User(
      id: _uuid.v4(),
      email: email,
      password: password,
      isLoggedIn: false,
    );

    await _userStorage.saveUser(user);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Register Success"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
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
                  'Create Account',
                  style: TextStyle(
                    fontFamily: 'TitanOne',
                    fontSize: 35,
                    color: AppColors.darkgrey(isDarkMode),
                    letterSpacing: 1.5,
                  ),
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
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                  decoration:
                      inputDecoration(
                        "Confirm Password",
                        Icons.lock,
                        themeProvider.isDarkMode,
                      ).copyWith(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 12, left: 6),
                          child: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.mainColor(isDarkMode),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: AppColors.mainColor(isDarkMode),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Register',
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
                      "Already have an account? ",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
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
    );
  }
}
