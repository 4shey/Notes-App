// import 'package:flutter_notes_app/models/todo.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ToDoStorage {
//   static String keyForUser(String userId) => 'todos_$userId';

//   Future<void> saveTodo(String userId, ToDoItem todo) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(keyForUser(userId), todo.toJson());
//   }

//   Future<ToDoItem?> loadNote(String userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final todoJson = prefs.getString(keyForUser(userId));
//     if (todoJson == null) return null;
//     return ToDoItem.fromJson(todoJson);
//   }
// }
