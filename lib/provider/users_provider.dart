import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/users.dart';
import 'package:flutter_notes_app/models/users_storage.dart';
import 'package:image_picker/image_picker.dart';

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
    await storage.logout(); // hapus is_logged_in + currentUserId
    _user = null; // reset user di provider
    notifyListeners(); // update UI
  }

  Future<void> pickAndUpdateProfileImage(BuildContext context) async {
    final picker = ImagePicker();

    // Pilih sumber gambar (camera/gallery)
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    isLoadingImage = true;
    notifyListeners();

    // Pick image langsung
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await File(
        pickedFile.path,
      ).readAsBytes(); // konversi ke Uint8List
      _user = _user?.copyWith(profileImage: bytes);

      if (_user != null) {
        await _storage.saveUser(_user!);
      }
    }

    isLoadingImage = false;
    notifyListeners();
  }
}
