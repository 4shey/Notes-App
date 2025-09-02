import 'package:flutter/material.dart';

class AppColors {
  // Light mode
  static const Color mainColorLight = Color(0xFFD9614C);
  static const Color backgroundColorLight = Color(0xFFF8EEE2);
  static const Color darkGreyLight = Color(0xFF403B36);
  static const Color lightGreyLight = Color(0xFF595550);
  static const Color whiteLight = Color(0xFFFFFDFA);
  static const Color cTodosColorLight = Color.fromARGB(86, 217, 97, 76);

  // Dark mode
  static const Color mainColorDark = Color(0xFF6EACDA);
  static const Color backgroundColorDark =  Color(0xFF1E1E1E);
  static const Color darkGreyDark = Color(0xFFCFCFCF);
  static const Color lightGreyDark = Color(0xFFAAAAAA);
  static const Color whiteDark = Colors.black;
  static const Color cTodosColorDark = Color.fromARGB(50, 110, 171, 218);

  static Color backgroundColor(bool isDarkMode) =>
      isDarkMode ? backgroundColorDark : backgroundColorLight;

  static Color darkgrey(bool isDarkMode) =>
      isDarkMode ? darkGreyDark : darkGreyLight;

  static Color lightGrey(bool isDarkMode) =>
      isDarkMode ? lightGreyDark : lightGreyLight;

  static Color white(bool isDarkMode) => isDarkMode ? whiteDark : whiteLight;

  static Color mainColor(bool isDarkMode) =>
      isDarkMode ? mainColorDark : mainColorLight;

  static Color completedTodosColor(bool isDarkmode) =>
      isDarkmode ? cTodosColorDark : const Color.fromARGB(56, 217, 97, 76);
}
