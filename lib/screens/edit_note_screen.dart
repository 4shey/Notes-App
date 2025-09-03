import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/users_storage.dart';
import 'package:flutter_notes_app/provider/note_provider.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:flutter_notes_app/widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';

OverlayEntry? _activeToast;
Timer? _toastTimer;

class EditNoteScreen extends StatefulWidget {
  final Note? existingNote;
  final int? noteIndex;

  const EditNoteScreen({super.key, this.existingNote, this.noteIndex});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

void showTopToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  _toastTimer?.cancel();
  _activeToast?.remove();

  _activeToast = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD9614C),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(_activeToast!);

  _toastTimer = Timer(const Duration(milliseconds: 1500), () {
    _activeToast?.remove();
    _activeToast = null;
  });
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    });
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.existingNote != null;
    final noteProvider = context.read<NoteProvider>();
    final userStorage = context.read<UserStorage>();

    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(isDarkMode),
      endDrawer: _buildCategoryDrawer(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditMode ? "Edit Note" : "Create Note",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.darkgrey(isDarkMode),
          ),
        ),
        leading: IconButton(
          icon: isDarkMode
              ? Image.asset('assets/images/arrow_dark.png', height: 22)
              : Image.asset('assets/images/arrow_back.png', height: 22),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          if (isEditMode)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.mainColor(isDarkMode),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => ConfirmDeleteDialog(
                      title: 'Confirm Delete',
                      content:
                          'Are you sure you want to delete "${widget.existingNote?.title}"?',
                    ),
                  );

                  if (confirm == true) {
                    noteProvider.delete(
                      noteProvider.notes.indexOf(widget.existingNote!),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          Builder(
            builder: (context) => IconButton(
              icon: isDarkMode
                  ? Image.asset('assets/images/bar_dark.png', height: 22)
                  : Image.asset('assets/images/bar_icon.png', height: 22),
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
                focusNode: _titleFocusNode,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkgrey(isDarkMode),
                ),
                decoration: const InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              TextField(
                controller: contentController,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightGrey(isDarkMode),
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
        backgroundColor: AppColors.mainColor(isDarkMode),
        onPressed: () async {
          if (titleController.text.isEmpty ||
              contentController.text.isEmpty ||
              selectedCategory == null) {
            showTopToast(context, "Please fill out all fields");
            return;
          }

          final currentUser = await userStorage.loadUser();
          if (currentUser == null) {
            showTopToast(context, "No user logged in");
            return;
          }

          final newNote = Note(
            userId: currentUser.id,
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
        },
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryDrawer() {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;

    final List<String> categoryOptions = ['personal', 'work', 'school'];

    return Drawer(
      backgroundColor: AppColors.white(isDarkMode),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.mainColor(isDarkMode)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Select Category",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                "Category",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkgrey(isDarkMode),
                ),
              ),
            ),
            ...categoryOptions.map((categoryOption) {
              final displayName = categoryOption == 'all'
                  ? 'All'
                  : categoryOption == 'favorites'
                  ? 'Favorites'
                  : '${categoryOption[0].toUpperCase()}${categoryOption.substring(1)}';

              return RadioListTile<String>(
                value: categoryOption,
                groupValue: selectedCategory,
                activeColor: AppColors.mainColor(isDarkMode),
                title: Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkgrey(isDarkMode),
                  ),
                ),
                onChanged: (value) {
                  setState(() => selectedCategory = value);
                  Navigator.pop(context);
                },
              );
            }).toList(),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
