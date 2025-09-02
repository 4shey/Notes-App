import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:flutter_notes_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class ToDoCard extends StatefulWidget {
  final ToDoItem todo;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  ToDoCard({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onTap,
  });

  @override
  State<ToDoCard> createState() => _ToDoCardState();
}

class _ToDoCardState extends State<ToDoCard> {
  bool _hovered = false;
  bool _pressed = false;

  Color _chipColor(String category) {
    switch (category) {
      case 'work':
        return const Color(0xFFCCE5FF);
      case 'school':
        return const Color(0xFFFFF3CD);
      default:
        return const Color(0xFFD4EDDA);
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'work':
        return 'Work';
      case 'school':
        return 'School';
      default:
        return 'Personal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;

    Color borderColor = widget.todo.isCompleted
        ? AppColors.mainColor(isDarkMode)
        : AppColors.darkgrey(isDarkMode);

    if (_hovered || _pressed) {
      borderColor = AppColors.mainColor(isDarkMode);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.todo.isCompleted
                ? AppColors.completedTodosColor(isDarkMode)
                : AppColors.white(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Row(
            children: [
              Checkbox(
                value: widget.todo.isCompleted,
                onChanged: (value) {
                  widget.onChanged(value);
                  TopToast.show(
                    context,
                    value == true
                        ? 'Task "${widget.todo.title}" completed'
                        : 'Task "${widget.todo.title}" uncomplete',
                    type: ToastType.info,
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: AppColors.mainColor(isDarkMode),
                checkColor: AppColors.white(isDarkMode),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.todo.title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        decoration: widget.todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: AppColors.darkgrey(isDarkMode),
                      ),
                    ),
                    if ((widget.todo.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.todo.description ?? '',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightGrey(isDarkMode),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _chipColor(widget.todo.category),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _categoryLabel(widget.todo.category),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.darkgrey(isDarkMode)),
            ],
          ),
        ),
      ),
    );
  }
}
