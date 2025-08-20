import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterDrawerTodo extends StatefulWidget {
  final String statusFilter; // filter status awal
  final String categoryFilter; // filter category awal
  final Function(String) onStatusSelected; // callback status ke parent
  final Function(String) onCategorySelected; // callback category ke parent

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
  late String _status; // status yang dipilih saat ini
  late String _category; // category yang dipilih saat ini
  final List<String> _categories = [
    'personal',
    'school',
    'work',
  ]; // daftar category

  @override
  void initState() {
    super.initState();
    _status = widget.statusFilter; // set status awal
    _category = widget.categoryFilter; // set category awal
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header Drawer
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

            // ===== Status Filter =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                "Status",
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
              ),
            ),
            // pilihan All
            RadioListTile<String>(
              title: Text(
                'All',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              value: 'all',
              groupValue: _status,
              activeColor: const Color(0xFFD9614C),
              onChanged: (v) {
                setState(() => _status = v!);
                widget.onStatusSelected(v!);
                Navigator.pop(context);
              },
            ),
            // pilihan Completed
            RadioListTile<String>(
              title: Text(
                'Completed',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              value: 'completed',
              groupValue: _status,
              activeColor: const Color(0xFFD9614C),
              onChanged: (v) {
                setState(() => _status = v!);
                widget.onStatusSelected(v!);
                Navigator.pop(context);
              },
            ),
            // pilihan Pending
            RadioListTile<String>(
              title: Text(
                'Pending',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              value: 'pending',
              groupValue: _status,
              activeColor: const Color(0xFFD9614C),
              onChanged: (v) {
                setState(() => _status = v!);
                widget.onStatusSelected(v!);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 24),

            // ===== Category Filter =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                "Category",
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
              ),
            ),
            // pilihan All category
            RadioListTile<String>(
              title: Text(
                'All',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              value: 'all',
              groupValue: _category,
              activeColor: const Color(0xFFD9614C),
              onChanged: (v) {
                setState(() => _category = v!);
                widget.onCategorySelected(v!);
                Navigator.pop(context);
              },
            ),
            // pilihan category dari list _categories
            ..._categories.map(
              (c) => RadioListTile<String>(
                title: Text(
                  c[0].toUpperCase() + c.substring(1),
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                value: c,
                groupValue: _category,
                activeColor: const Color(0xFFD9614C),
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
