import 'dart:convert';

import 'package:flutter_notes_app/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoStorage {
  static const String _key = 'todos_v1';

  static Future<List<ToDoItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list
        .map((s) => ToDoItem.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(List<ToDoItem> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final list = todos.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_key, list);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}