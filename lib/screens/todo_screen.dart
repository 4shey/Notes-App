import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:flutter_notes_app/models/users_storage.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/provider/todo_provider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:flutter_notes_app/widgets/empty_search.dart';
import 'package:flutter_notes_app/widgets/empty_state.dart';
import 'package:flutter_notes_app/widgets/filter_todos_drawer.dart';
import 'package:flutter_notes_app/widgets/todo_card.dart';
import 'package:flutter_notes_app/widgets/todo_dialog.dart';
import 'package:provider/provider.dart';

final GlobalKey<ToDoScreenState> toDoScreenKey = GlobalKey<ToDoScreenState>();

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  ToDoScreenState createState() => ToDoScreenState();
}

class ToDoScreenState extends State<ToDoScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _statusFilter = 'all';
  String _categoryFilter = 'all';
  bool _searchActive = false;
  String _searchQuery = '';

  static const _categories = ['personal', 'school', 'work'];

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

  void _closeSearch() {
    setState(() {
      _searchActive = false;
      _searchQuery = '';
    });
  }

  void closeSearchAndDrawer() {
    if (_searchActive) {
      setState(() {
        _searchActive = false;
        _searchQuery = "";
      });
    }
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  String _getHeaderTitle() {
    if (_statusFilter == 'completed') return 'Completed ToDos';
    if (_statusFilter == 'pending') return 'Pending ToDos';
    if (_categoryFilter == 'all') return 'All ToDos';
    return '${_categoryFilter[0].toUpperCase()}${_categoryFilter.substring(1)} ToDos';
  }

  List<ToDoItem> filteredTodos(List<ToDoItem> todos, String currentUserId) {
    // filter per user
    List<ToDoItem> userTodos = todos
        .where((t) => t.userId == currentUserId)
        .toList();

    // filter by status
    if (_statusFilter == 'completed') {
      userTodos = userTodos.where((t) => t.isCompleted).toList();
    } else if (_statusFilter == 'pending') {
      userTodos = userTodos.where((t) => !t.isCompleted).toList();
    }

    // filter by category
    if (_categoryFilter != 'all') {
      userTodos = userTodos
          .where((t) => t.category == _categoryFilter)
          .toList();
    }

    // filter by search query
    if (_searchQuery.isNotEmpty) {
      userTodos = userTodos
          .where(
            (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return userTodos;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final provider = context.watch<ToDoProvider>();
    final userStorage = context.read<UserStorage>();
    final currentUser = userStorage.loadUser(); // Future<User?>

    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;

    return FutureBuilder(
      future: currentUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userId = snapshot.data!.id;
        final todos = provider.todos;
        final displayedTodos = filteredTodos(todos, userId);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.backgroundColor(isDarkMode),
          resizeToAvoidBottomInset: false,
          drawer: _searchActive
              ? null
              : FilterDrawerTodo(
                  statusFilter: _statusFilter,
                  categoryFilter: _categoryFilter,
                  onStatusSelected: (value) =>
                      setState(() => _statusFilter = value),
                  onCategorySelected: (value) =>
                      setState(() => _categoryFilter = value),
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
                          if (!_searchActive)
                            Builder(
                              builder: (context) => IconButton(
                                icon: isDarkMode
                                    ? Image.asset(
                                        'assets/images/bar_dark.png',
                                        height: 20,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.asset(
                                        'assets/images/bar_icon.png',
                                        height: 20,
                                        fit: BoxFit.contain,
                                      ),
                                onPressed: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                              ),
                            ),
                          if (!_searchActive) const SizedBox(width: 10),
                          Expanded(
                            child: !_searchActive
                                ? Center(
                                    child: Text(
                                      _getHeaderTitle(),
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  )
                                : TextField(
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: 'Search todos by title...',
                                      filled: true,
                                      fillColor: AppColors.white(isDarkMode),
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
                                      setState(() => _searchQuery = value);
                                    },
                                  ),
                          ),
                          if (!_searchActive) const SizedBox(width: 10),
                          if (!_searchActive)
                            IconButton(
                              icon: isDarkMode
                                  ? Image.asset(
                                      'assets/images/search_dark.png',
                                      height: 20,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      'assets/images/search_icon.png',
                                      height: 20,
                                      fit: BoxFit.contain,
                                    ),
                              onPressed: () =>
                                  setState(() => _searchActive = true),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Builder(
                      builder: (_) {
                        if (displayedTodos.isEmpty) {
                          if (_searchActive && _searchQuery.isNotEmpty) {
                            return Center(
                              child: EmptySearchWidget(query: _searchQuery),
                            );
                          } else if (_statusFilter != 'all' ||
                              _categoryFilter != 'all') {
                            return Center(
                              child: EmptyDataWidget(
                                title: 'No ToDos',
                                subtitle: 'No todos found for your filter.',
                                screenSize:
                                    _screenSize ?? MediaQuery.of(context).size,
                              ),
                            );
                          } else if (todos
                              .where((t) => t.userId == userId)
                              .isEmpty) {
                            return Center(
                              child: EmptyDataWidget(
                                title: 'No ToDos yet',
                                subtitle: 'Tap "+" to add your todos.',
                                screenSize:
                                    _screenSize ?? MediaQuery.of(context).size,
                              ),
                            );
                          }
                        }

                        return ListView.builder(
                          key: const PageStorageKey("todosList"),
                          padding: const EdgeInsets.only(
                            bottom: 10,
                            left: 20,
                            right: 20,
                          ),
                          itemCount: displayedTodos.length,
                          itemBuilder: (context, index) {
                            final todo = displayedTodos[index];
                            final originalIndex = todos.indexOf(todo);
                            return ToDoCard(
                              todo: todo,
                              onChanged: (_) =>
                                  provider.toggleCompleted(originalIndex),
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => ToDoDialog(
                                    existing: todo,
                                    categories: _categories,
                                    onDelete: () {
                                      provider.delete(originalIndex);
                                    },
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
      },
    );
  }
}
