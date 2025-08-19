import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterDrawerTodo extends StatefulWidget {
  final String statusFilter;
  final String categoryFilter;
  final Function(String) onStatusSelected;
  final Function(String) onCategorySelected;

  const FilterDrawerTodo({
    super.key,
    required this.statusFilter,
    required this.categoryFilter,
    required this.onStatusSelected,
    required this.onCategorySelected,
  });

  @override
  State<FilterDrawerTodo> createState() => _FilterDrawerTodoState();
}

class _FilterDrawerTodoState extends State<FilterDrawerTodo> {
  late String _status;
  late String _category;
  final List<String> _categories = ['personal', 'school', 'work'];

  @override
  void initState() {
    super.initState();
    _status = widget.statusFilter;
    _category = widget.categoryFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFD9614C)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Filter ToDos",
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            // Status Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                "Status",
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
              ),
            ),
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _status,
              onChanged: (v) {
                setState(() => _status = v!);
                widget.onStatusSelected(v!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Completed'),
              value: 'completed',
              groupValue: _status,
              onChanged: (v) {
                setState(() => _status = v!);
                widget.onStatusSelected(v!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Pending'),
              value: 'pending',
              groupValue: _status,
              onChanged: (v) {
                setState(() => _status = v!);
                widget.onStatusSelected(v!);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 24),

            // Category Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                "Category",
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
              ),
            ),
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _category,
              onChanged: (v) {
                setState(() => _category = v!);
                widget.onCategorySelected(v!);
                Navigator.pop(context);
              },
            ),
            ..._categories.map(
              (c) => RadioListTile<String>(
                title: Text(c[0].toUpperCase() + c.substring(1)),
                value: c,
                groupValue: _category,
                onChanged: (v) {
                  setState(() => _category = v!);
                  widget.onCategorySelected(v!);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
