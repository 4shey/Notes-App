import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? existingNote; //null = tambah, not null = edit
  final int? noteIndex; // posisi

  const EditNoteScreen({super.key, this.existingNote, this.noteIndex});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  String? selectedCategory;

  @override
  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      titleController.text = widget.existingNote!.title;
      contentController.text = widget.existingNote!.content;
      selectedCategory = widget.existingNote!.category;
    } else {
      selectedCategory = "personal";
    }
  }

  Future<void> _saveNoteToPrefs(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notesStringList = prefs.getStringList('notes') ?? [];
    List<Note> notesList = notesStringList
        .map((str) => Note.fromJson(str))
        .toList();

    if (widget.existingNote != null && widget.noteIndex != null) {
      notesList[widget.noteIndex!] = note;
    } else {
      notesList.add(note);
    }

    List<String> updatedNotesStringList = notesList
        .map((note) => note.toJson())
        .toList();
    await prefs.setStringList('notes', updatedNotesStringList);
  }

  Future<void> _deleteNoteFromPrefs(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notesStringList = prefs.getStringList('notes') ?? [];
    if (index < 0 || index >= notesStringList.length) return;
    notesStringList.removeAt(index);
    await prefs.setStringList('notes', notesStringList);
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.existingNote != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8EEE2),
      endDrawer: _buildCategoryDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditMode ? "Edit Note" : "Create Note",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/arrow_back.png',
            height: 20,
            fit: BoxFit.contain,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                if (widget.noteIndex != null) {
                  await _deleteNoteFromPrefs(widget.noteIndex!);
                }
                Navigator.pop(context, {"action": "deleted"});
              },
            ),
          Builder(
            builder: (context) => IconButton(
              icon: Image.asset(
                'assets/images/bar_icon.png',
                height: 20,
                fit: BoxFit.contain,
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              TextField(
                controller: contentController,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: "Content",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFD9614C),
          onPressed: () async {
            if (titleController.text.isNotEmpty &&
                contentController.text.isNotEmpty &&
                selectedCategory != null) {
              final newNote = Note(
                title: titleController.text,
                content: contentController.text,
                category: selectedCategory!,
              );
              await _saveNoteToPrefs(newNote);
              Navigator.pop(context, {"action": "saved"});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Please fill out the title, content, and select a category',
                  ),
                  backgroundColor: const Color(0xFFD9614C),
                  behavior:
                      SnackBarBehavior.fixed,
                ),
              );
            }
          },
          child: const Icon(Icons.check, color: Colors.white),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Select Category',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Divider(),
            RadioListTile<String>(
              value: "personal",
              groupValue: selectedCategory,
              title: Text(
                "Personal",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: "work",
              groupValue: selectedCategory,
              title: Text(
                "Work",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              
              value: "school",
              groupValue: selectedCategory,
              title: Text(
                "School",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
