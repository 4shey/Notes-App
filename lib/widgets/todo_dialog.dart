import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/todo.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/provider/todo_provider.dart';
import 'package:flutter_notes_app/widgets/confirm_dialog.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
    category = widget.existing?.category ?? widget.categories.first;
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
    final provider = context.read<ToDoProvider>();
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    InputDecoration inputStyle(String label) => InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.nunito(
        fontWeight: FontWeight.w600,
        color: AppColors.lightGrey(isDarkMode),
      ),
      filled: true,
      fillColor: AppColors.white(isDarkMode),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightGrey(isDarkMode)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightGrey(isDarkMode)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.mainColor(isDarkMode),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.darkgrey(isDarkMode),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  widget.existing == null ? 'Add ToDo' : 'Edit ToDo',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.darkgrey(isDarkMode),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkgrey(isDarkMode),
                  ),
                  autofocus: true,
                  decoration: inputStyle('Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkgrey(isDarkMode),
                  ),
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
                      color: AppColors.darkgrey(isDarkMode),
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
                          color: selected
                              ? AppColors.white(isDarkMode)
                              : AppColors.darkgrey(isDarkMode),
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppColors.mainColor(isDarkMode),
                      backgroundColor: AppColors.white(isDarkMode),
                      checkmarkColor: AppColors.white(isDarkMode),
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
                          color: AppColors.mainColor(isDarkMode),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => ConfirmDeleteDialog(
                                title: 'Confirm Delete',
                                content:
                                    'Are you sure you want to delete "${widget.existing?.title}"?',
                              ),
                            );
                            if (confirm == true) {
                              provider.delete(
                                provider.todos.indexOf(widget.existing!),
                              );
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: canSave
                            ? AppColors.mainColor(isDarkMode)
                            : AppColors.lightGrey(isDarkMode),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.save, color: Colors.white),
                        onPressed: canSave
                            ? () {
                                final todo = ToDoItem(
                                  id:
                                      widget.existing?.id ??
                                      DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                  userId: provider.userId,
                                  title: titleController.text.trim(),
                                  description:
                                      descriptionController.text.trim().isEmpty
                                      ? null
                                      : descriptionController.text.trim(),
                                  category: category,
                                  isCompleted:
                                      widget.existing?.isCompleted ?? false,
                                );

                                if (widget.existing != null) {
                                  provider.addOrUpdate(
                                    todo,
                                    index: provider.todos.indexOf(
                                      widget.existing!,
                                    ),
                                  );
                                } else {
                                  provider.addOrUpdate(todo);
                                }

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
    );
  }
}
