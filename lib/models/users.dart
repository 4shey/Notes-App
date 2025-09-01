import 'dart:convert';
import 'dart:typed_data';

class User {
  String id; // Unique user id, bisa pakai UUID atau auto-generated
  String email;
  String password; // Bisa simpan hash untuk keamanan
  String name; // Optional
  bool isLoggedIn; // Untuk cek login sebelumnya
  Uint8List? profileImage;

  User({
    required this.id,
    required this.email,
    required this.password,
    this.name = '',
    this.isLoggedIn = false,
    this.profileImage,
  });
  
  User copyWith({
    String? id,
    String? email,
    String? password,
    String? fullName,
    bool? isLoggedIn,
    Uint8List? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  // Convert User ke Map untuk storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'isLoggedIn': isLoggedIn,
      'profileImage': profileImage != null ? base64Encode(profileImage!) : null,
    };
  }

  // Buat User dari Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'] ?? '',
      isLoggedIn: map['isLoggedIn'] ?? false,
      profileImage: map['profileImage'] != null
          ? base64Decode(map['profileImage'])
          : null,
    );
  }

  // Convert ke JSON
  String toJson() => json.encode(toMap());

  // Buat User dari JSON
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
