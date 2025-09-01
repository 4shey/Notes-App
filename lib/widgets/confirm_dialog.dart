import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:provider/provider.dart';
import '../theme/color.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    return AlertDialog(
      backgroundColor: AppColors.white(isDarkMode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
           Icon(Icons.warning_amber_rounded, color: AppColors.mainColor(isDarkMode)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
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
          child:  Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              color: AppColors.lightGrey(isDarkMode),
            ),
          ),
        ),

        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainColor(isDarkMode),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Delete',
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
