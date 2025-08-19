import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:flutter_notes_app/models/todo_storage.dart';
import 'package:flutter_notes_app/widgets/empty_search.dart';
import 'package:flutter_notes_app/widgets/empty_state.dart';
import 'package:flutter_notes_app/widgets/filter_todos_drawer.dart';
import 'package:flutter_notes_app/widgets/todo_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ToDoItem> _todos = [];
  bool _isLoading = true;

  // Filter & Search
  String _statusFilter = 'all';
  String _categoryFilter = 'all';
  bool _searchActive = false;
  String _searchQuery = '';

  static const _categories = ['personal', 'school', 'work'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await ToDoStorage.load();
    setState(() {
      _todos = loaded;
      _isLoading = false;
    });
  }

  Future<void> _save() async => ToDoStorage.save(_todos);

  List<int> get _displayIndices {
    final indices = <int>[];
    for (var i = 0; i < _todos.length; i++) {
      final t = _todos[i];

      // filter status
      if (_statusFilter == 'completed' && !t.isCompleted) continue;
      if (_statusFilter == 'pending' && t.isCompleted) continue;

      // filter category
      if (_categoryFilter != 'all' && t.category != _categoryFilter) continue;

      // search
      if (_searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        continue;
      }
      indices.add(i);
    }
    return indices;
  }

  void _toggleCompleted(int originalIndex) {
    setState(() {
      _todos[originalIndex].isCompleted = !_todos[originalIndex].isCompleted;
    });
    _save();
  }

  Future<void> _showTodoDialog({ToDoItem? existing, int? originalIndex}) async {
    String title = existing?.title ?? '';
    String description = existing?.description ?? '';
    String category = existing?.category ?? 'personal';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            final canSave = title.trim().isNotEmpty;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                existing == null ? 'Add ToDo' : 'Edit ToDo',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (v) => setLocal(() => title = v),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: title,
                            selection: TextSelection.collapsed(
                              offset: title.length,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Description (optional)',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 3,
                        onChanged: (v) => setLocal(() => description = v),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: description,
                            selection: TextSelection.collapsed(
                              offset: description.length,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category (single select)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Category',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((c) {
                          final selected = category == c;
                          return ChoiceChip(
                            label: Text(
                              c[0].toUpperCase() + c.substring(1),
                              style: GoogleFonts.nunito(
                                fontWeight: selected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                              ),
                            ),
                            selected: selected,
                            onSelected: (_) => setLocal(() => category = c),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (existing != null)
                  TextButton(
                    onPressed: () {
                      // delete
                      setState(() {
                        _todos.removeAt(originalIndex!);
                      });
                      _save();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: canSave
                      ? () {
                          if (existing == null) {
                            // add
                            setState(() {
                              _todos.add(
                                ToDoItem(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  title: title.trim(),
                                  description: (description.trim().isEmpty)
                                      ? null
                                      : description.trim(),
                                  category: category,
                                  isCompleted: false,
                                ),
                              );
                            });
                          } else {
                            // update
                            setState(() {
                              _todos[originalIndex!] = ToDoItem(
                                id: existing.id,
                                title: title.trim(),
                                description: (description.trim().isEmpty)
                                    ? null
                                    : description.trim(),
                                category: category,
                                isCompleted: existing.isCompleted,
                              );
                            });
                          }
                          _save();
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9614C),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(existing == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _closeSearch() {
    setState(() {
      _searchActive = false;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    const double topPadding = 18;
    const double horizontalPadding = 20;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8EEE2),
      drawer: _searchActive
          ? null
          : FilterDrawerTodo(
              statusFilter: _statusFilter,
              categoryFilter: _categoryFilter,
              onStatusSelected: (value) {
                setState(() {
                  _statusFilter = value;
                });
              },
              onCategorySelected: (value) {
                setState(() {
                  _categoryFilter = value;
                });
              },
            ),

      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_searchActive) _closeSearch();
          },
          child: Column(
            children: [
              const SizedBox(height: topPadding),
              // Header + Search
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      if (!_searchActive)
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
                      if (!_searchActive) const SizedBox(width: 10),
                      Expanded(
                        child: !_searchActive
                            ? Center(
                                child: Text(
                                  _statusFilter == "all"
                                      ? (_categoryFilter == 'all'
                                            ? 'All ToDos'
                                            : '${_categoryFilter[0].toUpperCase()}${_categoryFilter.substring(1)} ToDos')
                                      : _statusFilter == "completed"
                                      ? 'Completed ToDos'
                                      : 'Pending ToDos',
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
                                  hintText: 'Search todos by title...',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
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
                                  setState(() => _searchQuery = value);
                                },
                              ),
                      ),
                      if (!_searchActive) const SizedBox(width: 10),
                      if (!_searchActive)
                        IconButton(
                          icon: Image.asset(
                            'assets/images/search_icon.png',
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          onPressed: () {
                            setState(() => _searchActive = true);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_searchActive && _searchQuery.isNotEmpty)
                    ? (_displayIndices.isEmpty
                          ? Center(
                              child: EmptySearchWidget(query: _searchQuery),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              itemCount: _displayIndices.length,
                              itemBuilder: (context, idx) {
                                final originalIndex = _displayIndices[idx];
                                final todo = _todos[originalIndex];
                                return ToDoCard(
                                  todo: todo,
                                  onChanged: (_) =>
                                      _toggleCompleted(originalIndex),
                                  onTap: () => _showTodoDialog(
                                    existing: todo,
                                    originalIndex: originalIndex,
                                  ),
                                );
                              },
                            ))
                    : _todos.isEmpty
                    ? Center(
                        child: EmptyDataWidget(
                          title: 'No ToDos yet',
                          subtitle:
                              'Tap "+" to add your first todos.',
                          screenSize: MediaQuery.of(
                            context,
                          ).size,
                        ),
                      )
                    : _displayIndices.isEmpty
                    ? Center(
                        child: EmptyDataWidget(
                          title: 'No ToDos yet',
                          subtitle:
                              'Tap "+" to add your first todos.',
                          screenSize: MediaQuery.of(
                            context,
                          ).size,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        itemCount: _displayIndices.length,
                        itemBuilder: (context, idx) {
                          final originalIndex = _displayIndices[idx];
                          final todo = _todos[originalIndex];
                          return ToDoCard(
                            todo: todo,
                            onChanged: (_) => _toggleCompleted(originalIndex),
                            onTap: () => _showTodoDialog(
                              existing: todo,
                              originalIndex: originalIndex,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // ===== GANTI BUTTON MENJADI FAB DI POJOK KANAN BAWAH =====
      floatingActionButton: _searchActive
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFFD9614C),
              onPressed: () => _showTodoDialog(),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
