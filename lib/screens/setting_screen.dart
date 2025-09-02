import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/color.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(isDarkMode),
      
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: SwitchListTile(
            title: Text(
              isDarkMode ? 'Dark Mode' : 'Light Mode',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: AppColors.darkgrey(isDarkMode),
              ),
              textAlign: TextAlign.center,
            ),
            value: isDarkMode,
            onChanged: (value) => themeProvider.toggleDarkMode(value),
            activeColor: AppColors.mainColor(isDarkMode),
          ),
        ),
      ),
    );
  }
}
