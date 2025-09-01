// import 'package:flutter_notes_app/models/note.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NoteStorage {
//   static String keyForUser(String userId) => 'note_$userId';

//   Future<void> saveNote(String userId, Note note) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(keyForUser(userId), note.toJson());
//   }

//   Future<Note?> loadNote(String userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final noteJson = prefs.getString(keyForUser(userId));
//     if (noteJson == null) return null;
//     return Note.fromJson(noteJson);
//   }
// }
