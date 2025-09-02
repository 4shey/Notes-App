import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:flutter_notes_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool favorite;
  final VoidCallback? onFavoriteToggle;

  const NoteCard({
    super.key,
    required this.note,
    required this.favorite,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  favorite ? Icons.star : Icons.star_border,
                  color: favorite
                      ? Colors.yellow[700]
                      : AppColors.lightGrey(isDarkMode),
                ),
                onPressed: () {
                  if (onFavoriteToggle != null) {
                    onFavoriteToggle!();
                  }
                  TopToast.show(
                    context,
                    favorite
                        ? "Removed \"${note.title}\" from favorites"
                        : "Added \"${note.title}\" to favorites",
                    type: ToastType.info,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
