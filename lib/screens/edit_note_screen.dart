import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/note_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? existingNote;
  final int? noteIndex;

  const EditNoteScreen({super.key, this.existingNote, this.noteIndex});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String? selectedCategory;

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

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.existingNote != null;
    final noteProvider = context.read<NoteProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8EEE2),
      endDrawer: _buildCategoryDrawer(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditMode ? "Edit Note" : "Create Note",
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: Image.asset('assets/images/arrow_back.png', height: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isEditMode)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD9614C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: const [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFD9614C),
                          ),
                          SizedBox(width: 8),
                          Text('Confirm Delete'),
                        ],
                      ),
                     content: Text('Are you sure you want to delete "${widget.existingNote?.title}"?'),
                      actions: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD9614C),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && widget.noteIndex != null) {
                    await noteProvider.delete(widget.noteIndex!);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          Builder(
            builder: (context) => IconButton(
              icon: Image.asset('assets/images/bar_icon.png', height: 22),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
      floatingActionButton: FloatingActionButton(
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

            if (widget.noteIndex != null) {
              await noteProvider.addOrUpdate(newNote, index: widget.noteIndex);
            } else {
              await noteProvider.addOrUpdate(newNote);
            }

            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please fill out all fields"),
                backgroundColor: Color(0xFFD9614C),
              ),
            );
          }
        },
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Select Category",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Divider(),
            for (var c in ["personal", "work", "school"])
              RadioListTile<String>(
                value: c,
                groupValue: selectedCategory,
                title: Text(
                  c[0].toUpperCase() + c.substring(1),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onChanged: (value) {
                  setState(() => selectedCategory = value);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
