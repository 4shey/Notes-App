import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  late String _selectedStatus;
  late String _selectedCategory;

  final List<String> _statusOptions = ['all', 'completed', 'pending'];
  final List<String> _categoryOptions = ['personal', 'school', 'work'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.statusFilter;
    _selectedCategory = widget.categoryFilter;
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
                  "Filter ToDos",
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
                "Status",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkgrey(isDarkMode),
                ),
              ),
            ),
            ..._statusOptions.map((statusOption) {
              final displayName = statusOption == 'all'
                  ? 'All'
                  : statusOption[0].toUpperCase() + statusOption.substring(1);

              return RadioListTile<String>(
                title: Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkgrey(isDarkMode),
                  ),
                ),
                value: statusOption,
                groupValue: _selectedStatus,
                activeColor: AppColors.mainColor(isDarkMode),
                onChanged: (selectedStatus) {
                  setState(() => _selectedStatus = selectedStatus!);
                  widget.onStatusSelected(selectedStatus!);
                  Navigator.pop(context);
                },
              );
            }).toList(),

            const Divider(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                "Category",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkgrey(isDarkMode),
                ),
              ),
            ),

            RadioListTile<String>(
              title: Text(
                'All',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkgrey(isDarkMode),
                ),
              ),
              value: 'all',
              groupValue: _selectedCategory,
              activeColor: AppColors.mainColor(isDarkMode),
              onChanged: (selectedCategory) {
                setState(() => _selectedCategory = selectedCategory!);
                widget.onCategorySelected(selectedCategory!);
                Navigator.pop(context);
              },
            ),

            ..._categoryOptions.map((categoryOption) {
              final displayName =
                  categoryOption[0].toUpperCase() + categoryOption.substring(1);

              return RadioListTile<String>(
                title: Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkgrey(isDarkMode),
                  ),
                ),
                value: categoryOption,
                groupValue: _selectedCategory,
                activeColor: AppColors.mainColor(isDarkMode),
                onChanged: (selectedCategory) {
                  setState(() => _selectedCategory = selectedCategory!);
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
