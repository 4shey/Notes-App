import 'dart:convert';

class ToDoItem {
  String id;
  String userId; // user yang punya todo
  String title;
  String? description; // opsional
  String category;
  bool isCompleted;

  ToDoItem({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'category': category,
    'isCompleted': isCompleted,
  };

  factory ToDoItem.fromMap(Map<String, dynamic> map) => ToDoItem(
    id: map['id'] as String,
    userId: map['userId'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    category: (map['category'] as String?) ?? 'personal',
    isCompleted: (map['isCompleted'] as bool?) ?? false,
  );
  String toJson() => json.encode(toMap());

  factory ToDoItem.fromJson(String source) =>
      ToDoItem.fromMap(json.decode(source));
}
