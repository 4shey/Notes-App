
class ToDoItem {
  String id;
  String title;
  String? description;
  String category;
  bool isCompleted;

  ToDoItem({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'isCompleted': isCompleted,
  };

  factory ToDoItem.fromMap(Map<String, dynamic> map) => ToDoItem(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    category: (map['category'] as String?) ?? 'personal',
    isCompleted: (map['isCompleted'] as bool?) ?? false,
  );
}

