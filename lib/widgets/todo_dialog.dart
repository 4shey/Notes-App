import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:flutter_notes_app/screens/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class ToDoDialog extends StatefulWidget {
  final ToDoItem? existing;
  final List<String> categories;
  final VoidCallback? onDelete;
  final String todosTitle;
  final Function(ToDoItem)? onSave;

  const ToDoDialog({
    super.key,
    this.existing,
    required this.categories,
    this.onDelete,
    required this.todosTitle,
    this.onSave,
  });

  @override
  State<ToDoDialog> createState() => _ToDoDialogState();
}

class _ToDoDialogState extends State<ToDoDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late String category;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existing?.title ?? '');
    descriptionController = TextEditingController(
      text: widget.existing?.description ?? '',
    );
    category = widget.existing?.category ?? 'personal';

    titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = titleController.text.trim().isNotEmpty;

    InputDecoration inputStyle(String label) => InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.nunito(
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: mainColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      widget.existing == null ? 'Add ToDo' : 'Edit ToDo',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      autofocus: true,
                      decoration: inputStyle('Title'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      decoration: inputStyle('Description (optional)'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.categories.map((c) {
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
                          onSelected: (_) => setState(() => category = c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.existing != null && widget.onDelete != null)
                          Container(
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Row(
                                      children: const [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: mainColor,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Confirm Delete'),
                                      ],
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete "${widget.todosTitle}"',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    actionsPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    actions: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mainColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  widget.onDelete!();
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: canSave ? mainColor : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.save, color: Colors.white),
                            onPressed: canSave
                                ? () {
                                    widget.onSave?.call(
                                      ToDoItem(
                                        id:
                                            widget.existing?.id ??
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                        title: titleController.text.trim(),
                                        description:
                                            descriptionController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : descriptionController.text.trim(),
                                        category: category,
                                        isCompleted:
                                            widget.existing?.isCompleted ??
                                            false,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
