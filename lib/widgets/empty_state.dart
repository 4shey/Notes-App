import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmptyDataWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Size screenSize;

  const EmptyDataWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_notes_logo.png',
              height: screenSize.height * 0.25,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.darkgrey(isDarkMode),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.lightGrey(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
