import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/update_dialog.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      
      final response = await http.get(
        Uri.parse('https://plateq-backend.onrender.com/api/social/notifications'),
        headers: {'Authorization': 'Bearer $token'}
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications = jsonDecode(response.body);
          _isLoading = false;
        });
        
        // Update has_unread_notifications
        bool hasUnread = notifications.any((n) => n['isRead'] == false);
        await prefs.setBool('has_unread_notifications', hasUnread);
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_unread_notifications', false);
    
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isNotEmpty) {
      try {
        await http.put(
          Uri.parse('https://plateq-backend.onrender.com/api/social/notifications/read'),
          headers: {'Authorization': 'Bearer $token'}
        );
      } catch (e) {
        debugPrint("Error marking notifications as read: $e");
      }
    }
    
    setState(() {
      for (var notif in notifications) {
        notif["isRead"] = true;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua ditandai sudah dibaca"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Notifikasi",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              "Tandai Dibaca",
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text("Belum ada notifikasi", style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _buildNotificationItem(notif);
                },
              ),
    );
  }

  Widget _buildNotificationItem(dynamic notif) {
    IconData iconData;
    Color iconColor;
    
    String type = notif["type"] ?? "ANNOUNCEMENT";

    switch (type) {
      case "LIKE":
        iconData = Icons.favorite;
        iconColor = Colors.redAccent;
        break;
      case "COMMENT":
        iconData = Icons.chat_bubble;
        iconColor = Colors.blueAccent;
        break;
      case "FOLLOW":
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case "ADMIN_ANNOUNCEMENT":
        iconData = Icons.campaign;
        iconColor = Colors.orange;
        break;
      case "SUPERADMIN_ANNOUNCEMENT":
        iconData = Icons.verified;
        iconColor = Colors.blue;
        break;
      case "ANNOUNCEMENT":
        iconData = Icons.campaign;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return InkWell(
      onTap: () {
        final messageText = notif["message"] ?? 'Ada pemberitahuan baru!';
        if (messageText.contains('[UPDATE APK]')) {
          showDialog(
            context: context,
            builder: (context) => const UpdateDialog(),
          );
        } else if (type.contains('ANNOUNCEMENT')) {
          String titleStr = "Pemberitahuan Baru";
          if (type == 'SUPERADMIN_ANNOUNCEMENT') {
            titleStr = "📢 Pengumuman Penting!";
          } else if (type == 'ADMIN_ANNOUNCEMENT' || type == 'ANNOUNCEMENT') {
            titleStr = "ℹ️ Pengumuman";
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(titleStr, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Text(messageText.replaceAll('[INFO]', '').replaceAll('[EVENT]', '').trim()),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup"),
                ),
              ],
            )
          );
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notif["isRead"] ? Theme.of(context).colorScheme.surface : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF)),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(Theme.of(context).brightness == Brightness.dark ? 20 : 5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: notif["isRead"] ? null : Border.all(color: Colors.blue.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 12, color: iconColor),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14, height: 1.4),
                    children: [
                      TextSpan(text: notif["message"]),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Beberapa waktu yang lalu", // To do: add date formatting
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          if (!notif["isRead"])
            Container(
              margin: const EdgeInsets.only(top: 8, left: 8),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            )
        ],
      ),
    ));
  }
}
