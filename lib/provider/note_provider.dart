import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStringList = prefs.getStringList('notes') ?? [];
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
    await prefs.setStringList('notes', notesStringList);
  }
}
