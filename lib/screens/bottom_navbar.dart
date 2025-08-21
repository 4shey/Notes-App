import 'dart:math' as math;
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

  final List<Widget> _pages = [
    HomeScreen(key: homeScreenKey),
    ToDoScreen(key: toDoScreenKey),
  ];

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
      homeScreenKey.currentState
          ?.closeSearchAndDrawer(); // ✅ tutup search & drawer
      _openEditNoteScreen();
    } else if (_currentIndex == 1) {
      toDoScreenKey.currentState
          ?.closeSearchAndDrawer(); // ✅ tutup search & drawer
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
          if (index == 0) {
            homeScreenKey.currentState?.closeSearchAndDrawer(); // ✅
          } else if (index == 1) {
            toDoScreenKey.currentState?.closeSearchAndDrawer(); // ✅
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: SmoothVNotched(),
        notchMargin: 8,
        elevation: 0,
        color: Colors.white,
        child: SizedBox(
          height: 70,
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
              const Spacer(flex: 1), // ruang di tengah untuk FAB
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
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: mainColor,
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: mainColor,
          elevation: 0,
          highlightElevation: 0,
          onPressed: _onFabPressed,
          shape: const CircleBorder(),
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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (_currentIndex != index) {
          // 🔹 tutup search & drawer sebelum pindah tab
          if (_currentIndex == 0) {
            homeScreenKey.currentState?.closeSearchAndDrawer();
          } else if (_currentIndex == 1) {
            toDoScreenKey.currentState?.closeSearchAndDrawer();
          }

          // 🔹 pindah halaman
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
          );
        }
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

class SmoothVNotched extends NotchedShape {
  final double notchWidth; // lebar lekukan
  final double notchDepth; // kedalaman lekukan

  SmoothVNotched({this.notchWidth = 60, this.notchDepth = 20});

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final path = Path();
    path.moveTo(host.left, host.top);

    final centerX = guest.center.dx;
    final halfWidth = notchWidth / 2;

    // garis horizontal kiri sebelum lekukan
    path.lineTo(centerX - halfWidth, host.top);

    // garis miring kiri turun halus
    path.quadraticBezierTo(
      centerX - halfWidth / 2,
      host.top,
      centerX,
      host.top + notchDepth,
    );

    // garis miring kanan naik halus
    path.quadraticBezierTo(
      centerX + halfWidth / 2,
      host.top,
      centerX + halfWidth,
      host.top,
    );

    // garis horizontal kanan
    path.lineTo(host.right, host.top);
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();

    return path;
  }
}
