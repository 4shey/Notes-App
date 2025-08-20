import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/todo_provider.dart';
import 'package:flutter_notes_app/widgets/empty_search.dart';
import 'package:flutter_notes_app/widgets/empty_state.dart';
import 'package:flutter_notes_app/widgets/filter_todos_drawer.dart';
import 'package:flutter_notes_app/widgets/todo_card.dart';
import 'package:flutter_notes_app/widgets/todo_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _statusFilter = 'all';
  String _categoryFilter = 'all';
  bool _searchActive = false;
  String _searchQuery = '';

  static const _categories = ['personal', 'school', 'work'];

  void _closeSearch() {
    setState(() {
      _searchActive = false;
      _searchQuery = '';
    });
  }

  @override
  void initState() {
    super.initState();
    // load todos via provider
    final provider = Provider.of<ToDoProvider>(context, listen: false);
    provider.loadTodos();
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
                child: Consumer<ToDoProvider>(
                  builder: (context, provider, _) {
                    final todos = provider.todos;
                    final displayIndices = <int>[];

                    for (var i = 0; i < todos.length; i++) {
                      final t = todos[i];
                      if (_statusFilter == 'completed' && !t.isCompleted) continue;
                      if (_statusFilter == 'pending' && t.isCompleted) continue;
                      if (_categoryFilter != 'all' && t.category != _categoryFilter) continue;
                      if (_searchQuery.isNotEmpty &&
                          !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) continue;
                      displayIndices.add(i);
                    }

                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (displayIndices.isEmpty) {
                      return Center(
                        child: _searchActive && _searchQuery.isNotEmpty
                            ? EmptySearchWidget(query: _searchQuery)
                            : EmptyDataWidget(
                                title: 'No ToDos yet',
                                subtitle: 'Tap "+" to add your todos.',
                                screenSize: MediaQuery.of(context).size,
                              ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                      itemCount: displayIndices.length,
                      itemBuilder: (context, idx) {
                        final index = displayIndices[idx];
                        final todo = todos[index];
                        return ToDoCard(
                          todo: todo,
                          onChanged: (_) => provider.toggleCompleted(index),
                          onTap: () async {
                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => ToDoDialog(
                                existing: todo,
                                categories: _categories,
                                todosTitle: todo.title,
                                onSave: (t) => provider.updateTodo(index, t),
                                onDelete: () => provider.deleteTodo(index),
                              ),
                            );
                          },
                        );
                      },
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
