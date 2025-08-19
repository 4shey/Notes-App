import 'package:shared_preferences/shared_preferences.dart';
import 'note.dart';

class NoteStorage {
  static const String noteKey = 'my_note';

  Future<void> saveNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(noteKey, note.toJson());
  }

  Future<Note?> loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final noteJson = prefs.getString(noteKey);
    if (noteJson == null) return null;
    return Note.fromJson(noteJson);
  }
}
