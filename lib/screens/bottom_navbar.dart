import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/note.dart';
import 'package:flutter_notes_app/provider/todo_provider.dart';
import 'package:flutter_notes_app/screens/edit_note_screen.dart';
import 'package:flutter_notes_app/screens/home_screen.dart';
import 'package:flutter_notes_app/screens/todo_screen.dart';
import 'package:flutter_notes_app/widgets/todo_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const mainColor = Color(0xFFD9614C);

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;
  late PageController _pageController;
  List<Note> notes = [];
  bool isLoading = true;

  static const _categories = ['personal', 'school', 'work'];

  final List<Widget> _pages = [HomeScreen(), ToDoScreen()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _loadNotesFromPrefs();
  }

  Future<void> _openEditNoteScreen({Note? note, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditNoteScreen(existingNote: note, noteIndex: index),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final action = result['action'];

      setState(() {
        if (action == 'deleted' && index != null) {
          notes.removeAt(index);
        } else if (action == 'saved') {
          _loadNotesFromPrefs();
        }
      });
      _saveNotesToPrefs();
    }
  }

  Future<void> _loadNotesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStringList = prefs.getStringList('notes') ?? [];
    final loadedNotes = notesStringList
        .map((str) => Note.fromJson(str))
        .toList();

    setState(() {
      notes = loadedNotes;
      isLoading = false;
    });
  }

  Future<void> _saveNotesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStringList = notes.map((n) => n.toJson()).toList();
    await prefs.setStringList('notes', notesStringList);
  }

  void _onFabPressed() {
    if (_currentIndex == 0) {
      _openEditNoteScreen();
    } else if (_currentIndex == 1) {
      showDialog(
        context: context,
        builder: (_) => ToDoDialog(
          categories: _categories,
          todosTitle: '',
          onSave: (todo) {
            context.read<ToDoProvider>().addTodo(todo);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 8,
        color: Colors.white,
        child: SizedBox(
          height: 65,
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  Icons.note_outlined,
                  Icons.note,
                  "Notes",
                  0,
                ),
              ),
              const Spacer(),
              Expanded(
                child: _buildNavItem(
                  Icons.list_alt_outlined,
                  Icons.list_alt,
                  "To-Do",
                  1,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          backgroundColor: mainColor,
          shape: const CircleBorder(),
          onPressed: _onFabPressed,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: mainColor.withOpacity(isActive ? 1.0 : 0.5),
              size: isActive ? 28 : 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: mainColor.withOpacity(isActive ? 1.0 : 0.5),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
