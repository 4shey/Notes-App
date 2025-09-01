import 'dart:convert';
import 'package:flutter_notes_app/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String usersKey = 'users'; // Semua user disimpan di sini
  static const String currentUserIdKey = 'current_user_id';

  // Simpan atau update user
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersMap = await _loadUsersMap(prefs);

    usersMap[user.id] = user.toMap();
    await prefs.setString(usersKey, json.encode(usersMap));
    await prefs.setString(currentUserIdKey, user.id);
    await prefs.setBool('is_logged_in_${user.id}', true);
  }

  // Load current logged-in user
  Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString(currentUserIdKey);
    if (currentUserId == null) return null;

    final usersMap = await _loadUsersMap(prefs);
    final userMap = usersMap[currentUserId];
    if (userMap == null) return null;

    final isLoggedIn = prefs.getBool('is_logged_in_$currentUserId') ?? false;
    final user = User.fromMap(userMap);
    user.isLoggedIn = isLoggedIn;
    return user;
  }

  // Logout user (hapus status login saja)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString(currentUserIdKey);
    if (currentUserId != null) {
      await prefs.setBool('is_logged_in_$currentUserId', false);
      await prefs.remove(currentUserIdKey);
    }
  }

  // Login user by email & password
  Future<User?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersMap = await _loadUsersMap(prefs);

    for (var entry in usersMap.entries) {
      final user = User.fromMap(entry.value);
      if (user.email == email && user.password == password) {
        user.isLoggedIn = true;
        await prefs.setBool('is_logged_in_${user.id}', true);
        await prefs.setString(currentUserIdKey, user.id);
        return user;
      }
    }
    return null; // email/password salah
  }

  // Cek apakah ada user yang login
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString(currentUserIdKey);
    if (currentUserId == null) return false;
    return prefs.getBool('is_logged_in_$currentUserId') ?? false;
  }

  // Load semua user sebagai Map
  Future<Map<String, dynamic>> _loadUsersMap(SharedPreferences prefs) async {
    final usersString = prefs.getString(usersKey);
    if (usersString == null) return {};
    final Map<String, dynamic> map = json.decode(usersString);
    return map;
  }

  // Dapatkan semua user (opsional, misal buat switch akun)
  Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersMap = await _loadUsersMap(prefs);
    return usersMap.values.map((e) => User.fromMap(e)).toList();
  }
}
