import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/color.dart';
import 'package:provider/provider.dart';
import '../provider/theme_prrovider.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appName = info.appName;
      packageName = info.packageName;
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "App Info",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: AppColors.darkgrey(isDarkMode),
          ),
        ),
        backgroundColor: AppColors.backgroundColor(isDarkMode),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkgrey(isDarkMode)),
      ),
      backgroundColor: AppColors.backgroundColor(isDarkMode),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.apps),
            title: const Text("App Name"),
            subtitle: Text(appName),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text("Package Name"),
            subtitle: Text(packageName),
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text("Version"),
            subtitle: Text(version),
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: const Text("Build Number"),
            subtitle: Text(buildNumber),
          ),
        ],
      ),
    );
  }
}
