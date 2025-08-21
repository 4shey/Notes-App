import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:google_fonts/google_fonts.dart';

OverlayEntry? _activeToast;
Timer? _toastTimer;

class ToDoCard extends StatefulWidget {
  final ToDoItem todo;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const ToDoCard({
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

  void showTopToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    _toastTimer?.cancel();
    _activeToast?.remove();

    _activeToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFD9614C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_activeToast!);

    _toastTimer = Timer(const Duration(milliseconds: 1500), () {
      _activeToast?.remove();
      _activeToast = null;
    });
  }

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
    Color borderColor = widget.todo.isCompleted
        ? Colors.green.withOpacity(0.4)
        : Colors.grey;

    if (_hovered || _pressed) {
      borderColor = const Color(0xFFD9614C);
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
            color: widget.todo.isCompleted ? Colors.green[50] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Row(
            children: [
              Checkbox(
                value: widget.todo.isCompleted,
                onChanged: (value) {
                  widget.onChanged(value);
                  showTopToast(
                    context,
                    value == true
                        ? "Task \"${widget.todo.title}\" completed"
                        : "Task \"${widget.todo.title}\" marked incomplete",
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.todo.title,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        decoration: widget.todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: Colors.black87,
                      ),
                    ),
                    if ((widget.todo.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.todo.description!,
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
      ),
    );
  }
}
