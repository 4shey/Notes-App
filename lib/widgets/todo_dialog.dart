import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:google_fonts/google_fonts.dart';

class ToDoDialog extends StatefulWidget {
  final ToDoItem? existing;
  final List<String> categories;
  final VoidCallback? onDelete;

  const ToDoDialog({
    super.key,
    this.existing,
    required this.categories,
    this.onDelete,
  });

  @override
  State<ToDoDialog> createState() => _ToDoDialogState();
}

class _ToDoDialogState extends State<ToDoDialog> {
  // simple: pakai controller agar bisa edit data
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

    // simple: style input
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
        borderSide: const BorderSide(color: Color(0xFFD9614C), width: 2),
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
            // simple: agar tidak terpotong keyboard
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24), // simple: space untuk X
                    Text(
                      widget.existing == null ? 'Add ToDo' : 'Edit ToDo',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // simple: Title TextField
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      autofocus: true,
                      decoration: inputStyle('Title'),
                      onChanged: (_) => setState(() {}), // simple: enable Save
                    ),
                    const SizedBox(height: 16),

                    // simple: Description TextField
                    TextField(
                      controller: descriptionController,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      decoration: inputStyle('Description (optional)'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // simple: Categories
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

                    // simple: tombol Save/Delete dengan background
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.existing != null && widget.onDelete != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFD9614C),
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
                                          color: Color(0xFFD9614C),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Confirm Delete'),
                                      ],
                                    ),
                                    content: const Text(
                                      'Are you sure you want to delete this todos?',
                                      style: TextStyle(fontSize: 16),
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
                                          backgroundColor: const Color(
                                            0xFFD9614C,
                                          ),
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
                            color: canSave
                                ? const Color(0xFFD9614C)
                                : Colors
                                      .grey
                                      .shade400, // simple: ganti bg saat disable
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.save, color: Colors.white),
                            onPressed: canSave
                                ? () {
                                    Navigator.pop(
                                      context,
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
          // simple: X button pojok kanan atas
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
