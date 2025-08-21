import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';

OverlayEntry? _activeToast; 
Timer? _toastTimer;

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
  
void showTopToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  _toastTimer?.cancel();
  _activeToast?.remove();

  _activeToast = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD9614C),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(_activeToast!);

  // auto remove setelah 1.5 detik
  _toastTimer = Timer(const Duration(milliseconds: 1500), () {
    _activeToast?.remove();
    _activeToast = null;
  });
}


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  favorite ? Icons.star : Icons.star_border,
                  color: favorite ? Colors.yellow[700] : Colors.grey,
                ),
                onPressed: () {
                  if (onFavoriteToggle != null) {
                    onFavoriteToggle!();
                  }

                  showTopToast(
                    context,
                    favorite
                        ? "Removed \"${note.title}\" from favorites"
                        : "Added \"${note.title}\" to favorites",
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: GoogleFonts.nunito(
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
