import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/recipe_service.dart';
import '../services/update_service.dart';
import '../models/recipe_model.dart';

import '../screens/notification_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../theme/theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recipe>> _recipesFuture;
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Semua', 'Makanan', 'Minuman', 'Dessert'];
  bool _hasUnreadNotifications = false;
  Timer? _pollingTimer;
  int _lastNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _checkNotificationsLocal();
    _checkNotificationsFromServer(); // Fetch pertama kali
    
    // Mengecek versi aplikasi di background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkUpdate(context);
    });
    
    // Polling tiap 5 detik untuk mensimulasikan Push Notification (Pop-up)
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkNotificationsFromServer();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkNotificationsLocal() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _hasUnreadNotifications = prefs.getBool('has_unread_notifications') ?? false;
      });
    }
  }

  Future<void> _checkNotificationsFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      if (token.isEmpty) return;

      final response = await http.get(
        Uri.parse('http://192.168.101.127:3000/api/social/notifications'),
        headers: {'ngrok-skip-browser-warning': 'true', 'Authorization': 'Bearer $token'}
      );

      if (response.statusCode == 200) {
        final List<dynamic> notifs = jsonDecode(response.body);
        bool hasUnread = notifs.any((n) => n['isRead'] == false);
        
        if (mounted) {
          setState(() {
            _hasUnreadNotifications = hasUnread;
          });
        }
        await prefs.setBool('has_unread_notifications', hasUnread);

        // Jika jumlah notif bertambah dari sebelumnya, berarti ada notif baru masuk!
        if (notifs.length > _lastNotificationCount && _lastNotificationCount != 0) {
          final newNotif = notifs.first; // Notifikasi terbaru (desc)
          if (mounted && newNotif['isRead'] == false) {
            final String messageText = newNotif['message'] ?? 'Ada pemberitahuan baru!';
            
            // Tampilkan Pop-Up Dialog Biasa
              String titleStr = "Pemberitahuan Baru";
              if (newNotif['type'] == 'SUPERADMIN_ANNOUNCEMENT') {
                titleStr = "📢 Pengumuman Penting!";
              } else if (newNotif['type'] == 'ADMIN_ANNOUNCEMENT' || newNotif['type'] == 'ANNOUNCEMENT') {
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())).then((_) {
                          _checkNotificationsFromServer();
                        });
                      },
                      child: const Text("Lihat Notifikasi", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              );
          }
        }
        _lastNotificationCount = notifs.length;
      }
    } catch (e) {
      debugPrint("Polling error: $e");
    }
  }

  void _fetchRecipes() {
    final List<int?> categoryIds = [null, 1, 3, 4];
    setState(() {
      _recipesFuture = RecipeService.fetchRecipes(
        categoryId: categoryIds[_selectedCategoryIndex],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 1. Top Bar: Dark Mode Icon & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        ThemeManager.isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFD4AF37) : Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        ThemeManager.toggleTheme();
                      },
                    ),
                  ),
                  const Text(
                    "Plate'Q",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Notification Bell with Red Dot
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.black54),
                          onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                            _checkNotificationsFromServer();
                          },
                        ),
                      ),
                      if (_hasUnreadNotifications)
                        Positioned(
                        top: 8,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),



              // 3. Categories Row
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                        _fetchRecipes();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 4. Daftar Resep (Grid)
              Expanded(
                child: FutureBuilder<List<Recipe>>(
                  future: _recipesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Belum ada resep."));
                    }

                    final allRecipes = snapshot.data!;
                    List<Recipe> recipes = allRecipes;
                    if (_selectedCategoryIndex != 0) {
                      final selectedCategoryName = _categories[_selectedCategoryIndex];
                      recipes = allRecipes.where((r) => r.categoryName == selectedCategoryName).toList();
                    }

                    if (recipes.isEmpty) {
                      return const Center(child: Text("Belum ada resep di kategori ini."));
                    }

                    int columns = MediaQuery.of(context).size.width > 1200 ? 5 : (MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2));

                    return RefreshIndicator(
                      onRefresh: () async { _fetchRecipes(); },
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75, // Mengatur proporsi tinggi vs lebar kartu
                        ),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(recipe: recipes[index]),
                                ),
                              );
                            },
                            child: RecipeGridCard(recipe: recipes[index]),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Khusus untuk Menampilkan Kartu Resep (Grid Item)
class RecipeGridCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeGridCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bagian Atas: Gambar (atau kotak abu-abu jika kosong)
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest, // Abu-abu kebiruan lembut
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: recipe.image != null
                        ? Hero(
                            tag: 'recipe-image-${recipe.id}',
                            child: Image.network(
                              'http://192.168.101.127:3000/uploads/${recipe.image}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
              // Bagian Bawah: Informasi
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Oleh: ${recipe.authorName}',
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (recipe.authorRole == 'ADMIN' || recipe.authorRole == 'SUPERADMIN')
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(Icons.verified, color: Colors.blue, size: 12),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            recipe.cookingTime,
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
