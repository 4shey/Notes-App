import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:google_fonts/google_fonts.dart';

class ToDoCard extends StatelessWidget {
  final ToDoItem todo;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const ToDoCard({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onTap,
  });

  Color _chipColor(String category) {
    switch (category) {
      case 'work':
        return const Color(0xFFCCE5FF);
      case 'school':
        return const Color(0xFFFFF3CD);
      default:
        return const Color(0xFFD4EDDA); // personal
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: todo.isCompleted ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: todo.isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: todo.isCompleted,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    todo.title,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: Colors.black87,
                    ),
                  ),
                  // Description
                  if ((todo.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      todo.description!,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _chipColor(todo.category),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _categoryLabel(todo.category),
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}