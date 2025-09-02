import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/theme_prrovider.dart';
import 'package:flutter_notes_app/provider/users_provider.dart';
import 'package:flutter_notes_app/widgets/exit_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_notes_app/screens/login_screen.dart';
import 'package:flutter_notes_app/widgets/edit_profile.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showAppInfo(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("App Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("App Name: ${info.appName}"),
            Text("Package: ${info.packageName}"),
            Text("Version: ${info.version}"),
            Text("Build: ${info.buildNumber}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<EditProfileProvider>();
    final user = userProvider.user;

    final themeProvider = context.watch<ThemeProvider>();
    bool isDarkMode = themeProvider.isDarkMode;

    final displayName = (user?.name.isNotEmpty ?? false) ? user!.name : "guest";
    final email = user?.email ?? "guest@mail.com";

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(isDarkMode),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Notely',
                style: const TextStyle(fontFamily: 'TitanOne', fontSize: 20),
              ),
              const SizedBox(height: 32),
              // avatar + edit
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await userProvider.pickAndUpdateProfileImage(context);
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user?.profileImage != null
                            ? MemoryImage(user!.profileImage!) as ImageProvider
                            : const AssetImage("assets/images/avatar.png"),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.white(isDarkMode),
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: AppColors.mainColor(isDarkMode),
                          ),
                        ),
                      ),
                      if (userProvider.isLoadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkgrey(isDarkMode),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.lightGrey(isDarkMode),
                ),
              ),
              const SizedBox(height: 32),

              // Menu Items
              _buildMenuItem(context, Icons.edit, "Edit Profile", () async {
                if (user == null) return;
                final result = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (context) => EditProfileDialog(user: user),
                );
                if (result != null) {
                  userProvider.updateProfile(
                    name: result["name"],
                    email: result["email"],
                  );
                }
              }, isDarkMode),

              // App Theme toggle langsung
              SwitchListTile(
                secondary: Icon(
                  Icons.brightness_6,
                  color: AppColors.mainColor(isDarkMode),
                ),
                title: Text(
                  'App Theme',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkgrey(isDarkMode),
                  ),
                ),
                value: isDarkMode,
                onChanged: (value) => themeProvider.toggleDarkMode(value),
                activeColor: AppColors.mainColor(isDarkMode),
              ),

              // // App Info
              // ListTile(
              //   leading: Icon(
              //     Icons.info,
              //     color: AppColors.mainColor(isDarkMode),
              //   ),
              //   title: Text(
              //     'App Info',
              //     style: GoogleFonts.nunito(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: AppColors.darkgrey(isDarkMode),
              //     ),
              //   ),
              //   onTap: () => _showAppInfo(context),
              // ),

              _buildMenuItem(context, Icons.logout, "Log Out", () async {
                await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmCloseDialog(
                    title: "Konfirmasi",
                    content: "Apakah yakin ingin logout?",
                    onConfirm: () async {
                      final provider = context.read<EditProfileProvider>();
                      await provider.logout();

                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                );
              }, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mainColor(isDarkMode)),
      title: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkgrey(isDarkMode),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.darkgrey(isDarkMode),
      ),
      onTap: onTap,
    );
  }
}
