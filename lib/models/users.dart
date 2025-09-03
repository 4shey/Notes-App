import 'dart:convert';
import 'dart:typed_data';

class User {
  String id;
  String email;
  String password;
  String name;
  bool isLoggedIn;
  Uint8List? profileImage;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    this.isLoggedIn = false,
    this.profileImage,
  });

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    bool? isLoggedIn,
    Uint8List? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      profileImage: profileImage ?? this.profileImage,
    );
  }

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

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
