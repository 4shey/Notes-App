import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/users.dart';
import 'package:flutter_notes_app/models/users_storage.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileProvider with ChangeNotifier {
  final UserStorage _storage = UserStorage();
  User? _user;

  User? get user => _user;
  bool isLoadingImage = false;

  Future<void> setUser(User user) async {
    _user = user;
    await _storage.saveUser(user);
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    _user = await _storage.loadUser();
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (_user == null) return;

    _user = _user!.copyWith(name: name, email: email);

    await _storage.saveUser(_user!);
    notifyListeners();
  }

  Future<void> logout() async {
    final storage = UserStorage();
    await storage.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> pickAndUpdateProfileImage(BuildContext context,bool isDarkMode) async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white(isDarkMode),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: AppColors.darkgrey(isDarkMode),
              ),
              title: Text(
                "Camera",
                style: TextStyle(color: AppColors.darkgrey(isDarkMode)),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo, color: AppColors.darkgrey(isDarkMode)),
              title: Text(
                "Gallery",
                style: TextStyle(color: AppColors.darkgrey(isDarkMode)),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    isLoadingImage = true;
    notifyListeners();

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      _user = _user?.copyWith(profileImage: bytes);

      if (_user != null) {
        await _storage.saveUser(_user!);
      }
    }

    isLoadingImage = false;
    notifyListeners();
  }
}
