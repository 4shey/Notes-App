import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
