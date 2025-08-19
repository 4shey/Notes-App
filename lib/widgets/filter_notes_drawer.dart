import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterDrawerHome extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const FilterDrawerHome({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<FilterDrawerHome> createState() => _FilterDrawerHomeState();
}

class _FilterDrawerHomeState extends State<FilterDrawerHome> {
  late String _currentCategory;

  final List<String> _categories = ['all', 'favorites', 'personal', 'work', 'school'];

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
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
                  'Filter Notes',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Category',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ..._categories.map((c) {
              final displayName = c == 'all'
                  ? 'All'
                  : c == 'favorites'
                      ? 'Favorites'
                      : '${c[0].toUpperCase()}${c.substring(1)}';
              return RadioListTile<String>(
                title: Text(
                  displayName,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                value: c,
                groupValue: _currentCategory,
                activeColor: const Color(0xFFD9614C),
                onChanged: (v) {
                  setState(() => _currentCategory = v!);
                  widget.onCategorySelected(v!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
