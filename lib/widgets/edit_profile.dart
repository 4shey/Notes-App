import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/users.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:flutter_notes_app/widgets/input_decoration.dart';
import 'package:flutter_notes_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class EditProfileDialog extends StatefulWidget {
  final User user;

  const EditProfileDialog({super.key, required this.user});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.backgroundColor(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Edit Profile",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.darkgrey(isDarkMode),
              ),
            ),
            const SizedBox(height: 34),
            TextField(
              controller: _nameController,
              decoration: inputDecoration(
                'Name',
                Icons.person,
                themeProvider.isDarkMode,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: inputDecoration(
                'Email',
                Icons.email,
                themeProvider.isDarkMode,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightGrey(isDarkMode),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();

                    if (!email.endsWith('@gmail.com')) {
                      TopToast.show(
                        context,
                        "Email must end with @gmail.com",
                        type: ToastType.error,
                      );
                      return;
                    }

                    Navigator.pop(context, {
                      "name": _nameController.text.trim(),
                      "email": email,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor(isDarkMode),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: AppColors.white(isDarkMode),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
