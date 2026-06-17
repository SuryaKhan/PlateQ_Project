import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../core/config/app_config.dart';

class UpdateService {
  static const String baseUrl = 'https://publisher-neurotic-affluent.ngrok-free.dev/api/app';

  static Future<void> checkUpdate(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/version/latest'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestBuildNumber = data['buildNumber'] as int;

        if (latestBuildNumber > AppConfig.appBuildNumber) {
          if (!context.mounted) return;
          _showUpdateDialog(
            context,
            data['versionString'],
            data['releaseNotes'] ?? "Ada pembaruan penting untuk Plate'Q!",
            data['apkUrl'],
            data['isMandatory'] ?? false,
          );
        }
      }
    } catch (e) {
      debugPrint("Gagal mengecek update: $e");
    }
  }

  static void _showUpdateDialog(
    BuildContext context,
    String version,
    String releaseNotes,
    String apkUrl,
    bool isMandatory,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !isMandatory, // Jika mandatory, user tidak bisa tutup dialog
      builder: (context) {
        return PopScope(
          canPop: !isMandatory,
          child: AlertDialog(
            title: const Text("Versi Baru Tersedia! 🎉"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Plate'Q versi $version sudah dirilis.",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(releaseNotes),
              ],
            ),
            actions: [
              if (!isMandatory)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Nanti", style: TextStyle(color: Colors.grey)),
                ),
              ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(apkUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    debugPrint("Could not launch $url");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB48A36), // Warna emas Plate'Q
                ),
                child: const Text("Update Sekarang"),
              ),
            ],
          ),
        );
      },
    );
  }
}
