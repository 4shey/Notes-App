import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class EmptySearchWidget extends StatelessWidget {
  final String query;

  const EmptySearchWidget({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/empty.json',
            height: MediaQuery.of(context).size.height * 0.35,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            'No results for "$query"',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different keyword or clear the search.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
