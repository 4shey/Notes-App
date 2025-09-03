import 'package:flutter/material.dart';
import '../theme/color.dart';

InputDecoration inputDecoration(String label, IconData icon, bool isDarkMode) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: AppColors.darkgrey(isDarkMode),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.mainColor(isDarkMode), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: AppColors.darkgrey(isDarkMode),
        width: 1.5,
      ),
    ),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 12, right: 6),
      child: Icon(icon, color: AppColors.mainColor(isDarkMode)),
    ),
    filled: true,
    fillColor: AppColors.white(isDarkMode),
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
  );
}
