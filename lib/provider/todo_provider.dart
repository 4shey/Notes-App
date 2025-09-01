import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoProvider extends ChangeNotifier {
  late String userId; // ID user untuk filter data

  ToDoProvider({required this.userId});

  List<ToDoItem> _todos = [];

  List<ToDoItem> get todos => _todos;

  String get _storageKey => 'todos_$userId'; // key unik per user

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStringList = prefs.getStringList(_storageKey) ?? [];
    _todos = notesStringList.map((str) => ToDoItem.fromJson(str)).toList();
    notifyListeners();
  }

  Future<void> addOrUpdate(ToDoItem todo, {int? index}) async {
    if (index != null) {
      _todos[index] = todo;
    } else {
      _todos.add(todo);
    }
    await _save();
    notifyListeners();
  }

  Future<void> delete(int index) async {
    _todos.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> toggleCompleted(int index) async {
    _todos[index].isCompleted = !_todos[index].isCompleted;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStringList = _todos.map((n) => n.toJson()).toList();
    await prefs.setStringList(_storageKey, notesStringList);
  }

  Future<void> clearTodos() async {
    _todos.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> setUserIdAndLoad(String newUserId) async {
    userId = newUserId; // update userId
    await loadTodos(); // load data sesuai user baru
  }
}
