import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteProvider extends ChangeNotifier {
  late String userId; // ID user untuk filter data

  NoteProvider({required this.userId});

  List<Note> _notes = [];

  List<Note> get notes => _notes;

  String get _storageKey => 'notes_$userId'; // key unik per user

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStringList = prefs.getStringList(_storageKey) ?? [];
    _notes = notesStringList.map((str) => Note.fromJson(str)).toList();
    notifyListeners();
  }

  Future<void> addOrUpdate(Note note, {int? index}) async {
    if (index != null) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    await _save();
    notifyListeners();
  }

  Future<void> delete(int index) async {
    _notes.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> toggleFavorite(int index) async {
    _notes[index].favorite = !_notes[index].favorite;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStringList = _notes.map((n) => n.toJson()).toList();
    await prefs.setStringList(_storageKey, notesStringList);
  }

  Future<void> clearNotes() async {
    _notes.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> setUserIdAndLoad(String newUserId) async {
    userId = newUserId; // update userId
    await loadNotes(); // load data sesuai user baru
  }
}
