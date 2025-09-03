import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notes_app/models/note.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/screens/edit_note_screen.dart';
import 'package:flutter_notes_app/screens/home_screen.dart';
import 'package:flutter_notes_app/screens/todo_screen.dart';
import 'package:flutter_notes_app/screens/profile_screen.dart';
import 'package:flutter_notes_app/widgets/exit_dialog.dart';
import 'package:flutter_notes_app/widgets/todo_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/users_storage.dart';
import '../theme/color.dart';
import 'package:provider/provider.dart';

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
  late String userId;
  late List<Widget> _pages;

  static const _categories = ['personal', 'school', 'work'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _initUser();
  }

  Future<void> _initUser() async {
    final userStorage = UserStorage();
    final currentUser = await userStorage.loadUser();
    if (currentUser != null) {
      userId = currentUser.id;
      _loadNotesFromPrefs();
    }
  }

  Future<void> _loadNotesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final notesStringList = prefs.getStringList('notes_$userId') ?? [];
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
    await prefs.setStringList('notes_$userId', notesStringList);
  }

  void _onFabPressed() {
    if (_currentIndex == 0) {
      homeScreenKey.currentState?.closeSearchAndDrawer();
      _openEditNoteScreen();
    } else if (_currentIndex == 1) {
      toDoScreenKey.currentState?.closeSearchAndDrawer();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ToDoDialog(categories: _categories, onDelete: null),
      );
    }
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
        if (action == 'deleted' && index != null)
          notes.removeAt(index);
        else if (action == 'saved')
          _loadNotesFromPrefs();
      });
      _saveNotesToPrefs();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    _pages = [
      HomeScreen(key: homeScreenKey),
      ToDoScreen(key: toDoScreenKey),
      ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        bool shouldClose = false;

        await showDialog(
          context: context,
          builder: (context) => ConfirmCloseDialog(
            onConfirm: () {
              shouldClose = true;
              SystemNavigator.pop();
            },
          ),
        );

        return shouldClose ? false : false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white(isDarkMode),
        resizeToAvoidBottomInset: false,
        body: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            if (index == 0)
              homeScreenKey.currentState?.closeSearchAndDrawer();
            else if (index == 1)
              toDoScreenKey.currentState?.closeSearchAndDrawer();
          },
        ),
        bottomNavigationBar: BottomAppBar(
          shape: SmoothVNotched(),
          notchMargin: 8,
          elevation: 0,
          color: AppColors.white(isDarkMode),
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
                    isDarkMode,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    Icons.list_alt_outlined,
                    Icons.list_alt,
                    "To-Do",
                    1,
                    isDarkMode,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    Icons.person_outline,
                    Icons.person,
                    "Profile",
                    2,
                    isDarkMode,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _currentIndex == 2 || _currentIndex == 3
            ? null
            : Transform.translate(
                offset: const Offset(-5, -5),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.mainColor(isDarkMode),
                    elevation: 6,
                    onPressed: _onFabPressed,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, size: 32, color: Colors.white),
                  ),
                ),
              ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    bool isDarkMode,
  ) {
    bool isActive = _currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (_currentIndex != index) {
          if (_currentIndex == 0) {
            homeScreenKey.currentState?.closeSearchAndDrawer();
          } else if (_currentIndex == 1) {
            toDoScreenKey.currentState?.closeSearchAndDrawer();
          }

          setState(() => _currentIndex = index);
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
              icon,
              color: AppColors.mainColor(
                isDarkMode,
              ).withOpacity(isActive ? 1 : 0.5),
              size: isActive ? 28 : 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.mainColor(
                  isDarkMode,
                ).withOpacity(isActive ? 1 : 0.5),
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
  final double notchWidth;
  final double notchDepth;
  SmoothVNotched({this.notchWidth = 60, this.notchDepth = 20});

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);

    final path = Path();
    path.moveTo(host.left, host.top);
    final centerX = guest.center.dx;
    final halfWidth = notchWidth / 2;

    path.lineTo(centerX - halfWidth, host.top);
    path.quadraticBezierTo(
      centerX - halfWidth / 2,
      host.top,
      centerX,
      host.top + notchDepth,
    );
    path.quadraticBezierTo(
      centerX + halfWidth / 2,
      host.top,
      centerX + halfWidth,
      host.top,
    );

    path.lineTo(host.right, host.top);
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();
    return path;
  }
}
