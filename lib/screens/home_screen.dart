import 'package:flutter/material.dart';
import 'package:flutter_notes_app/screens/edit_note_screen.dart';
import 'package:flutter_notes_app/widgets/empty_search.dart';
import 'package:flutter_notes_app/widgets/empty_state.dart';
import 'package:flutter_notes_app/widgets/filter_notes_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Note> notes = [];
  bool isLoading = true;

  String selectedCategory = "all";
  String searchQuery = "";
  bool searchActive = false;

  Size? _screenSize;

  @override
  void initState() {
    super.initState();
    _loadNotesFromPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _screenSize = MediaQuery.of(context).size;
      });
    });
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

  List<Note> get filteredNotes {
    List<Note> baseFiltered;

    if (selectedCategory == "favorites") {
      baseFiltered = notes.where((n) => n.favorite).toList();
    } else if (selectedCategory != "all") {
      baseFiltered = notes
          .where((n) => n.category == selectedCategory)
          .toList();
    } else {
      baseFiltered = List.from(notes);
    }

    if (searchQuery.isNotEmpty) {
      baseFiltered = baseFiltered
          .where(
            (note) =>
                note.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return baseFiltered;
  }

  void toggleFavorite(int index) {
    setState(() {
      notes[index].favorite = !notes[index].favorite;
    });
    _saveNotesToPrefs();
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

  void _closeSearch() {
    setState(() {
      searchActive = false;
      searchQuery = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = 18;
    final double horizontalPadding = 20;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8EEE2),
      drawer: searchActive
          ? null
          : FilterDrawerHome(
              selectedCategory: selectedCategory,
              onCategorySelected: (value) {
                setState(() {
                  selectedCategory = value;
                  searchActive = false;
                  searchQuery = "";
                });
              },
            ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (searchActive) _closeSearch();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  SizedBox(height: topPadding),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          if (!searchActive)
                            Builder(
                              builder: (context) => IconButton(
                                icon: Image.asset(
                                  'assets/images/bar_icon.png',
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                                onPressed: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                              ),
                            ),
                          if (!searchActive) const SizedBox(width: 10),
                          Expanded(
                            child: !searchActive
                                ? Center(
                                    child: Text(
                                      selectedCategory == "all"
                                          ? 'All Notes'
                                          : selectedCategory == "favorites"
                                          ? 'Favorites'
                                          : '${selectedCategory[0].toUpperCase()}${selectedCategory.substring(1)} Notes',
                                      style: GoogleFonts.nunito(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  )
                                : TextField(
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: 'Search notes by title...',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: _closeSearch,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                  ),
                          ),
                          if (!searchActive) const SizedBox(width: 10),
                          if (!searchActive)
                            Builder(
                              builder: (context) => IconButton(
                                icon: Image.asset(
                                  'assets/images/search_icon.png',
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                                onPressed: () {
                                  setState(() {
                                    searchActive = true;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredNotes.isEmpty
                        ? searchActive && searchQuery.isNotEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      EmptySearchWidget(query: searchQuery),
                                    ],
                                  ),
                                )
                              : EmptyDataWidget(
                                  title: 'No Notes yet',
                                  subtitle:
                                      'Tap the + button to add your first note.',
                                  screenSize: _screenSize ?? const Size(0, 0),
                                )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 0,
                            ),
                            child: MasonryGridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = filteredNotes[index];
                                final originalIndex = notes.indexOf(note);

                                return GestureDetector(
                                  onTap: () => _openEditNoteScreen(
                                    note: note,
                                    index: originalIndex,
                                  ),
                                  child: NoteCard(
                                    note: note,
                                    favorite: note.favorite,
                                    onFavoriteToggle: () =>
                                        toggleFavorite(originalIndex),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      floatingActionButton: searchActive
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFFD9614C),
              onPressed: () => _openEditNoteScreen(),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
    );
  }
}
