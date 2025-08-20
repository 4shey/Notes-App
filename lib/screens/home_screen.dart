import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/note.dart';
import 'package:flutter_notes_app/provider/note_provider.dart';
import 'package:flutter_notes_app/screens/edit_note_screen.dart';
import 'package:flutter_notes_app/widgets/empty_search.dart';
import 'package:flutter_notes_app/widgets/empty_state.dart';
import 'package:flutter_notes_app/widgets/filter_notes_drawer.dart';
import 'package:flutter_notes_app/widgets/note_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedCategory = "all";
  String searchQuery = "";
  bool searchActive = false;

  Size? _screenSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _screenSize = MediaQuery.of(context).size;
      });
    });
  }

  Future<void> _openEditNoteScreen({Note? note, int? index}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditNoteScreen(existingNote: note, noteIndex: index),
      ),
    );
    // Tidak perlu setState, provider akan rebuild otomatis
  }

  List<Note> filteredNotes(List<Note> notes) {
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

  void _closeSearch() {
    setState(() {
      searchActive = false;
      searchQuery = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final notes = noteProvider.notes;
    final displayedNotes = filteredNotes(notes);

    return Scaffold(
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
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                onPressed: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
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
                                      setState(() => searchQuery = value);
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
                                onPressed: () =>
                                    setState(() => searchActive = true),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: notes.isEmpty
                        ? EmptyDataWidget(
                            title: 'No Notes yet',
                            subtitle: 'Tap the + button to add your note.',
                            screenSize: _screenSize ?? const Size(0, 0),
                          )
                        : displayedNotes.isEmpty
                        ? searchActive && searchQuery.isNotEmpty
                              ? Center(
                                  child: EmptySearchWidget(query: searchQuery),
                                )
                              : EmptyDataWidget(
                                  title: 'No Notes yet',
                                  subtitle:
                                      'Tap the + button to add your note.',
                                  screenSize: _screenSize ?? const Size(0, 0),
                                )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: MasonryGridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              itemCount: displayedNotes.length,
                              itemBuilder: (context, index) {
                                final note = displayedNotes[index];
                                final originalIndex = notes.indexOf(note);
                                return GestureDetector(
                                  onTap: () => _openEditNoteScreen(
                                    note: note,
                                    index: originalIndex,
                                  ),
                                  child: NoteCard(
                                    note: note,
                                    favorite: note.favorite,
                                    onFavoriteToggle: () {
                                      noteProvider.toggleFavorite(
                                        originalIndex,
                                      );
                                    },
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
    );
  }
}
