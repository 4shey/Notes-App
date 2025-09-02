import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:provider/provider.dart';
import '../theme/color.dart';

enum ToastType { success, error, info }

class TopToast extends StatefulWidget {
  final String message;
  final Duration duration;
  final ToastType type;

  const TopToast({
    super.key,
    required this.message,
    required this.duration,
    required this.type,
  });

  static OverlayEntry? _activeEntry;
  static Timer? _timer;
  static GlobalKey<_TopToastState>? _activeKey;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
    ToastType type = ToastType.info,
  }) {
    final overlay = Overlay.of(context);

    // kalau ada toast aktif → update aja isinya
    if (_activeEntry != null && _activeKey?.currentState != null) {
      _activeKey!.currentState!.updateContent(message, type);
      _timer?.cancel();
      _timer = Timer(duration, () async {
        if (_activeKey?.currentState != null) {
          await _activeKey!.currentState!.hide();
        }
        _activeEntry?.remove();
        _activeEntry = null;
        _activeKey = null;
      });
      return;
    }

    // kalau belum ada toast aktif → bikin baru
    final key = GlobalKey<_TopToastState>();
    final entry = OverlayEntry(
      builder: (context) =>
          TopToast(key: key, message: message, duration: duration, type: type),
    );

    _activeKey = key;
    _activeEntry = entry;
    overlay.insert(entry);

    _timer?.cancel();
    _timer = Timer(duration, () async {
      if (_activeKey?.currentState != null) {
        await _activeKey!.currentState!.hide(); // animasi keluar
      }
      _activeEntry?.remove();
      _activeEntry = null;
      _activeKey = null;
    });
  }

  @override
  State<TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<TopToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  String _message = "";
  ToastType _type = ToastType.info;

  @override
  void initState() {
    super.initState();
    _message = widget.message;
    _type = widget.type;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // mulai dari atas
      end: Offset.zero, // ke posisi normal
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward(); // animasi masuk
  }

  void updateContent(String newMessage, ToastType newType) {
    setState(() {
      _message = newMessage;
      _type = newType;
    });
  }

  Future<void> hide() async {
    await _controller.reverse(); // animasi keluar ke atas
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (_type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.info:
        return Icons.info;
    }
  }

  Color _getBackgroundColor(bool isDarkMode) {
    switch (_type) {
      case ToastType.success:
        return AppColors.mainColor(isDarkMode);
      case ToastType.error:
        return AppColors.mainColor(isDarkMode);
      case ToastType.info:
        return AppColors.mainColor(isDarkMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(isDarkMode),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getIcon(), color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
