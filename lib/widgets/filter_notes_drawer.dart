import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:provider/provider.dart';

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

  final List<String> _categories = [
    'all',
    'favorites',
    'personal',
    'work',
    'school',
  ];

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
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
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.mainColor(isDarkMode)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Filter Notes',
                  style: TextStyle(
                    fontFamily: 'Nunito',
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
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkgrey(isDarkMode),
                ),
              ),
            ),
            ..._categories.map((category) {
              final displayName = category == 'all'
                  ? 'All'
                  : category == 'favorites'
                  ? 'Favorites'
                  : '${category[0].toUpperCase()}${category.substring(1)}';

              return RadioListTile<String>(
                title: Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkgrey(isDarkMode),
                  ),
                ),
                value: category,
                groupValue: _currentCategory,
                activeColor: AppColors.mainColor(isDarkMode),
                onChanged: (selectedCategory) {
                  setState(() => _currentCategory = selectedCategory!);
                  widget.onCategorySelected(selectedCategory!);
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
