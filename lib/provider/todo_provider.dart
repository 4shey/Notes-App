import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:flutter_notes_app/models/todo_storage.dart';

class ToDoProvider extends ChangeNotifier {
  List<ToDoItem> _todos = [];
  bool _isLoading = true;

  List<ToDoItem> get todos => _todos;
  bool get isLoading => _isLoading;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    _todos = await ToDoStorage.load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo(ToDoItem todo) async {
    _todos.add(todo);
    await ToDoStorage.save(_todos);
    notifyListeners();
  }

  Future<void> updateTodo(int index, ToDoItem todo) async {
    _todos[index] = todo;
    await ToDoStorage.save(_todos);
    notifyListeners();
  }

  Future<void> deleteTodo(int index) async {
    _todos.removeAt(index);
    await ToDoStorage.save(_todos);
    notifyListeners();
  }

  Future<void> toggleCompleted(int index) async {
    _todos[index].isCompleted = !_todos[index].isCompleted;
    await ToDoStorage.save(_todos);
    notifyListeners();
  }
}
