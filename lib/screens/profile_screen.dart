import 'package:flutter/material.dart';
import 'package:flutter_notes_app/provider/users_provider.dart';
import 'package:flutter_notes_app/widgets/confirm_dialog.dart';
import 'package:flutter_notes_app/widgets/exit_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_notes_app/screens/login_screen.dart';
import 'package:flutter_notes_app/widgets/edit_profile.dart';
import 'package:flutter_notes_app/theme/color.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final bool isDarkMode;

  const ProfileScreen({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditProfileProvider>();
    final user = provider.user;

    final displayName = (user?.name.isNotEmpty ?? false)
        ? user!.name
        : "ambatukam";

    final email = user?.email ?? "example@mail.com";

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
                style: TextStyle(fontFamily: 'TitanOne', fontSize: 20),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await provider.pickAndUpdateProfileImage(context);
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
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      if (provider.isLoadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
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
              _buildMenuItem(context, Icons.edit, "Edit Profile", () async {
                if (user == null) return;
                final result = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (context) => EditProfileDialog(user: user),
                );
                if (result != null) {
                  provider.updateProfile(
                    name: result["name"],
                    email: result["email"],
                  );
                }
              }),
              _buildMenuItem(context, Icons.logout, "Log Out", () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmDeleteDialog(
                    title: "Konfirmasi",
                    content: "Apakah yakin ingin logout?",
                  ),
                );

                if (confirm == true) {
                  final provider = context.read<EditProfileProvider>();
                  await provider.logout();

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              }),
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
