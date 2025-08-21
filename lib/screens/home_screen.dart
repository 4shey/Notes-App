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

final GlobalKey<_HomeScreenState> homeScreenKey = GlobalKey<_HomeScreenState>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedCategory = "all";
  String searchQuery = "";
  bool searchActive = false;

  Size? _screenSize;

  @override
  bool get wantKeepAlive => true;

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
          .where((note) =>
              note.title.toLowerCase().contains(searchQuery.toLowerCase()))
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

  void closeSearchAndDrawer() {
    if (searchActive) {
      setState(() {
        searchActive = false;
        searchQuery = "";
      });
    }
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final noteProvider = context.watch<NoteProvider>();
    final notes = noteProvider.notes;
    final displayedNotes = filteredNotes(notes);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
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
                            onPressed: () => setState(() => searchActive = true),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Builder(
                  builder: (_) {
                    // logic empty state mirip todos
                    if (displayedNotes.isEmpty) {
                      if (searchActive && searchQuery.isNotEmpty) {
                        return Center(
                          child: EmptySearchWidget(query: searchQuery),
                        );
                      } else if (selectedCategory != "all") {
                        return Center(
                          child: EmptyDataWidget(
                            title: 'No Notes',
                            subtitle: 'No notes found for your filter.',
                            screenSize: _screenSize ?? const Size(0, 0),
                          ),
                        );
                      } else if (notes.isEmpty) {
                        return Center(
                          child: EmptyDataWidget(
                            title: 'No Notes yet',
                            subtitle: 'Tap the + button to add your note.',
                            screenSize: _screenSize ?? const Size(0, 0),
                          ),
                        );
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        padding: const EdgeInsets.only(bottom: 20),
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
                                noteProvider.toggleFavorite(originalIndex);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
