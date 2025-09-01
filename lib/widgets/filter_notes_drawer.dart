import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FilterDrawerHome extends StatefulWidget {
  final String selectedCategory; // category awal yang dipilih
  final Function(String) onCategorySelected; // callback ke parent

  const FilterDrawerHome({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<FilterDrawerHome> createState() => _FilterDrawerHomeState();
}

class _FilterDrawerHomeState extends State<FilterDrawerHome> {
  late String _currentCategory; // category yang sedang dipilih

  final List<String> _categories = ['all', 'favorites', 'personal', 'work', 'school']; // daftar category

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory; // set category awal
  }

  @override
  Widget build(BuildContext context) {
    
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    return Drawer(
      backgroundColor: AppColors.white(isDarkMode),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header drawer
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.mainColor(isDarkMode)), // warna background
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Filter Notes', // judul drawer
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            // Label Category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Category', // teks label
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            // List Radio untuk tiap category
            ..._categories.map((c) {
              final displayName = c == 'all' // tampilkan All
                  ? 'All'
                  : c == 'favorites' // tampilkan Favorites
                      ? 'Favorites'
                      : '${c[0].toUpperCase()}${c.substring(1)}'; // capitalize huruf pertama
              return RadioListTile<String>(
                title: Text(
                  displayName, // teks category
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                value: c, // nilai category
                groupValue: _currentCategory, // category yang sedang dipilih
                activeColor: AppColors.mainColor(isDarkMode), // warna saat dipilih
                onChanged: (v) {
                  setState(() => _currentCategory = v!); // update category
                  widget.onCategorySelected(v!); // kirim ke parent
                  Navigator.pop(context); // tutup drawer
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
