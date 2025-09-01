import 'dart:convert';

class Note {
  String userId; // ID user pemilik note
  String title;
  String content;
  String category;
  bool favorite;

  Note({
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.favorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'category': category,
      'favorite': favorite,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      userId: map['userId'], // ambil userId dari storage
      title: map['title'],
      content: map['content'],
      category: map['category'],
      favorite: map['favorite'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));
}
