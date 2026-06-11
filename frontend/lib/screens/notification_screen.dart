import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy Notifikasi
    final List<Map<String, dynamic>> notifications = [
      {
        "type": "like",
        "name": "Siti Aminah",
        "action": "menyukai resep Anda",
        "target": "Nasi Goreng Spesial",
        "time": "10 mnt",
        "isRead": false,
      },
      {
        "type": "comment",
        "name": "Chef Juna",
        "action": "mengomentari resep Anda",
        "target": "Sup Tomat Klasik",
        "time": "1 jam",
        "isRead": false,
      },
      {
        "type": "follow",
        "name": "Rina Nose",
        "action": "mulai mengikuti Anda",
        "target": "",
        "time": "3 jam",
        "isRead": true,
      },
      {
        "type": "like",
        "name": "Budi Santoso",
        "action": "menyukai resep Anda",
        "target": "Salad Musim Semi",
        "time": "Kemarin",
        "isRead": true,
      },
      {
        "type": "comment",
        "name": "Ahmad Dani",
        "action": "membalas komentar Anda di",
        "target": "Pasta Vongole",
        "time": "Kemarin",
        "isRead": true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Background seragam
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFE2E8F0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Logika mark all as read
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua ditandai sudah dibaca")));
            },
            child: const Text(
              "Tandai Dibaca",
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return _buildNotificationItem(notif);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif) {
    IconData iconData;
    Color iconColor;

    switch (notif["type"]) {
      case "like":
        iconData = Icons.favorite;
        iconColor = Colors.redAccent;
        break;
      case "comment":
        iconData = Icons.chat_bubble;
        iconColor = Colors.blueAccent;
        break;
      case "follow":
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notif["isRead"] ? Colors.white : const Color(0xFFEFF6FF), // Biru sangat muda jika belum dibaca
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: notif["isRead"] ? null : Border.all(color: Colors.blue.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Small Icon overlay
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 12, color: iconColor),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, height: 1.4),
                    children: [
                      TextSpan(text: notif["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " ${notif["action"]}"),
                      if (notif["target"].isNotEmpty)
                        TextSpan(text: " \"${notif["target"]}\"", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notif["time"],
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          // Indikator Titik (Unread)
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
    );
  }
}
