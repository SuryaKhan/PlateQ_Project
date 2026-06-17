import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'manage_users_screen.dart';
import 'manage_recipes_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalRecipes = 0;
  int _trendingLikes = 0;
  int _reportsCount = 0;
  List<int> _growthData = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      
      final response = await http.get(
        Uri.parse('http://192.168.101.133:3000/api/admin/stats'),
        headers: {'ngrok-skip-browser-warning': 'true', 
          'Authorization': 'Bearer $token'
        }
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _totalUsers = data['totalUsers'] ?? 0;
          _totalRecipes = data['totalRecipes'] ?? 0;
          _trendingLikes = data['trending'] ?? 0;
          _reportsCount = data['reports'] ?? 0;
          if (data['growthData'] != null) {
            _growthData = List<int>.from(data['growthData']);
          }
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      debugPrint("Error fetching stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = const Color(0xFFD4AF37);
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Dashboard Analitik",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grafik Pertumbuhan
            Text(
              "Pertumbuhan Pengguna",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 20, // Hanya render di kelipatan 20
                        getTitlesWidget: (value, meta) {
                          if (value % 20 != 0) return const SizedBox();
                          return Text(value.toInt().toString(), style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1, // Hanya render label bulat (0, 1, 2, dll.)
                        getTitlesWidget: (value, meta) {
                          const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                          if (value.toInt() < 0 || value.toInt() >= days.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()], style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _growthData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
                      isCurved: true,
                      color: goldColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: goldColor.withAlpha(30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Ringkasan Platform
            Text(
              "Ringkasan Platform",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(context, "Total User", _totalUsers.toString(), Icons.people, goldColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, "Resep Aktif", _totalRecipes.toString(), Icons.restaurant_menu, Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(context, "Total Like", "+$_trendingLikes", Icons.favorite, Colors.pinkAccent)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, "Komentar", _reportsCount.toString(), Icons.chat, Colors.orangeAccent)),
              ],
            ),
            const SizedBox(height: 32),

            // Aktivitas & Tindakan Cepat
            Text(
              "Tindakan Cepat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            _buildActionRow(context, "Kelola Pengguna", "Blokir atau hapus akun pengguna", Icons.shield, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageUsersScreen())).then((_) => _fetchStats());
            }),
            _buildActionRow(context, "Moderasi Resep", "Tinjau atau hapus resep", Icons.gavel, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageRecipesScreen())).then((_) => _fetchStats());
            }),
            _buildActionRow(context, "Kirim Pengumuman", "Kirim notifikasi global via email/banner", Icons.campaign, onTap: () {
              _showAnnouncementDialog(context);
            }),
            _buildActionRow(context, "Publish Update Aplikasi", "Wajibkan user untuk update APK", Icons.system_update, onTap: () {
              _showPublishUpdateDialog(context);
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              Icon(Icons.more_horiz, color: isDark ? Colors.grey : Colors.black45, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'INFO';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Kirim Pengumuman Global"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InputDecorator(
                  decoration: const InputDecoration(labelText: "Jenis Pengumuman"),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: "INFO", child: Text("Info Umum")),
                        DropdownMenuItem(value: "UPDATE_APK", child: Text("Update Aplikasi")),
                        DropdownMenuItem(value: "EVENT", child: Text("Event / Lomba")),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Judul Pengumuman"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: "Isi Pengumuman"),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.white),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('jwt_token') ?? '';
                  try {
                    final response = await http.post(
                      Uri.parse('http://192.168.101.133:3000/api/admin/announcements'),
                      headers: {'ngrok-skip-browser-warning': 'true', 
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token'
                      },
                      body: jsonEncode({
                        'title': titleController.text,
                        'content': contentController.text,
                        'category': selectedCategory,
                      }),
                    );
                    
                    if (!context.mounted) return;
                    
                    if (response.statusCode == 201) {
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengumuman berhasil disebarkan!")));
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response.body}")));
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }, 
                child: const Text("Sebarkan!")
              ),
            ],
          );
        }
      )
    );
  }

  void _showPublishUpdateDialog(BuildContext context) {
    final versionController = TextEditingController();
    final buildNumberController = TextEditingController();
    final releaseNotesController = TextEditingController();
    final apkUrlController = TextEditingController();
    bool isMandatory = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Publish Update Aplikasi"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: versionController,
                    decoration: const InputDecoration(labelText: "Versi (ex: 1.0.1)"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: buildNumberController,
                    decoration: const InputDecoration(labelText: "Build Number (ex: 2)"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: releaseNotesController,
                    decoration: const InputDecoration(labelText: "Release Notes"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: apkUrlController,
                    decoration: const InputDecoration(labelText: "APK Download URL (G-Drive/Mediafire)"),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text("Mandatory Update?"),
                    value: isMandatory,
                    onChanged: (val) => setState(() => isMandatory = val ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.white),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('jwt_token') ?? '';
                  try {
                    final response = await http.post(
                      Uri.parse('http://192.168.101.133:3000/api/app/version'),
                      headers: {'ngrok-skip-browser-warning': 'true', 
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token'
                      },
                      body: jsonEncode({
                        'versionString': versionController.text,
                        'buildNumber': int.tryParse(buildNumberController.text) ?? 1,
                        'releaseNotes': releaseNotesController.text,
                        'apkUrl': apkUrlController.text,
                        'isMandatory': isMandatory,
                      }),
                    );
                    
                    if (!context.mounted) return;
                    
                    if (response.statusCode == 201) {
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pembaruan berhasil dipublish!")));
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response.body}")));
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }, 
                child: const Text("Publish")
              ),
            ],
          );
        }
      )
    );
  }

  Widget _buildActionRow(BuildContext context, String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
}
