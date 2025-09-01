import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:provider/provider.dart';
import '../theme/color.dart';

class ConfirmCloseDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmCloseDialog({
    super.key,
    this.title = 'Confirm',
    this.content = 'Are you sure you want to close?',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    
    return AlertDialog(
      backgroundColor: AppColors.white(isDarkMode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: AppColors.darkgrey(isDarkMode)
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkgrey(isDarkMode)
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              color: AppColors.lightGrey(isDarkMode),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainColor(isDarkMode),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Ok',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              color: AppColors.white(isDarkMode),
            ),
          ),
        ),
      ],
    );
  }
}
