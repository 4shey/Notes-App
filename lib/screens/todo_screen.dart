import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:flutter_notes_app/models/todo_storage.dart';
import 'package:flutter_notes_app/widgets/empty_search.dart';
import 'package:flutter_notes_app/widgets/empty_state.dart';
import 'package:flutter_notes_app/widgets/filter_todos_drawer.dart';
import 'package:flutter_notes_app/widgets/todo_card.dart';
import 'package:flutter_notes_app/widgets/todo_dialog.dart';
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
      if (_statusFilter == 'completed' && !t.isCompleted) continue;
      if (_statusFilter == 'pending' && t.isCompleted) continue;
      if (_categoryFilter != 'all' && t.category != _categoryFilter) continue;
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

  void _closeSearch() {
    setState(() {
      _searchActive = false;
      _searchQuery = '';
    });
  }

  Future<void> _openTodoDialog({ToDoItem? existing, int? originalIndex}) async {
    final result = await showDialog<ToDoItem>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ToDoDialog(
        existing: existing,
        categories: _categories,
        onDelete: existing != null
            ? () => _deleteTodo(originalIndex!)
            : null,
      ),
    );

    if (result != null) {
      setState(() {
        if (existing == null) {
          _todos.add(result);
        } else {
          _todos[originalIndex!] = result;
        }
      });
      _save();
    }
  }

  Future<void> _deleteTodo(int index) async {
    setState(() {
      _todos.removeAt(index);
    });
    _save();
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
                setState(() => _statusFilter = value);
              },
              onCategorySelected: (value) {
                setState(() => _categoryFilter = value);
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
                    : (_displayIndices.isEmpty
                        ? Center(
                            child: _searchActive && _searchQuery.isNotEmpty
                                ? EmptySearchWidget(query: _searchQuery)
                                : EmptyDataWidget(
                                    title: 'No ToDos yet',
                                    subtitle: 'Tap "+" to add your todos.',
                                    screenSize: MediaQuery.of(context).size,
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
                                onChanged: (_) =>
                                    _toggleCompleted(originalIndex),
                                onTap: () => _openTodoDialog(
                                  existing: todo,
                                  originalIndex: originalIndex,
                                ),
                              );
                            },
                          )),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFD9614C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
        onPressed: () => _openTodoDialog(),
      ),
    );
  }
}
