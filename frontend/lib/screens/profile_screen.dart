import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import '../models/recipe_model.dart';
import 'recipe_detail_screen.dart';
import 'admin_dashboard_screen.dart';
import '../theme/theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  int _selectedTabIndex = 0; // 0 = Resepku, 1 = Favorit, 2 = Komentar

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final data = await AuthService.getProfile();
    setState(() {
      _profileData = data;
      _isLoading = false;
    });
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Gagal memuat profil."),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text("Coba Lagi"),
              )
            ],
          ),
        ),
      );
    }

    final user = _profileData!;
    final List<dynamic> myRecipesRaw = user['myRecipes'] ?? [];
    
    final List<Recipe> myRecipes = myRecipesRaw.map((r) => Recipe(
      id: r['id'],
      title: r['title'],
      content: r['content'],
      authorName: user['name'] ?? user['username'],
      authorRole: user['role'] ?? 'USER',
      image: r['image'],
      difficulty: r['difficulty'] ?? 'Mudah',
      cookingTime: r['cookingTime'] ?? '30 Min',
    )).toList();

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
              icon: Icon(
                ThemeManager.isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              onPressed: () {
                ThemeManager.toggleTheme();
              },
            ),
          ),
        ),
        title: const Text(
          "Plate'Q",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar Section
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: const Color(0xFFE2E8F0),
                          backgroundImage: user['profileImage'] != null 
                              ? NetworkImage('http://192.168.1.5:3000/uploads/${user['profileImage']}') 
                              : null,
                          child: user['profileImage'] == null 
                              ? const Icon(Icons.person, size: 55, color: Colors.grey) 
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB48A36), // Warna emas/mustard mockup
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Name and Bio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user['name'] ?? user['username'] ?? 'User',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      if (user['role'] == 'ADMIN' || user['role'] == 'SUPERADMIN')
                        const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: Icon(Icons.verified, color: Colors.blue, size: 20),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "@${user['username']}",
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      user['bio'] ?? "Penikmat masakan nusantara yang hobi berbagi resep tradisional dengan sentuhan modern",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons (Edit Profile & Share)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                          _loadProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2E8F0),
                          foregroundColor: const Color(0xFF1E293B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur bagikan segera hadir!")));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF94A3B8), // Warna abu-abu slate
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Bagikan", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (user['role'] == 'ADMIN' || user['role'] == 'SUPERADMIN')
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                          );
                        },
                        icon: const Icon(Icons.admin_panel_settings, size: 18),
                        label: const Text("Admin Panel"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B), // Biru gelap
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Tab Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton(0, "Resepku", Icons.restaurant_menu),
                      const SizedBox(width: 8),
                      _buildTabButton(1, "Favorit", Icons.favorite_border),
                      const SizedBox(width: 8),
                      _buildTabButton(2, "Komentar", Icons.chat_bubble_outline),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Tab Content
          _buildTabContent(myRecipes),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (index != 0) // Mockup tidak menunjukkan ikon di 'Resepku', tapi ada di yg lain? Oh di mockup ada 'Favorit' dgn hati, dll.
              Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            if (index != 0) const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<Recipe> myRecipes) {
    if (_selectedTabIndex == 0) {
      // Tab Resepku (Grid)
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        sliver: myRecipes.isEmpty 
          ? const SliverToBoxAdapter(child: Center(child: Text("Belum ada resep yang dibuat.")))
          : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildGridCard(myRecipes[index], showFavoriteIcon: false);
                },
                childCount: myRecipes.length,
              ),
            ),
      );
    } else if (_selectedTabIndex == 1) {
      // Tab Favorit (Grid Dummy dengan Ikon Hati)
      // Buat data dummy favorit untuk keperluan UI
      final dummyFavorites = [
        Recipe(id: 991, title: 'Salad Musim Semi', content: '', authorName: '', authorRole: 'USER', image: null, difficulty: 'Mudah', cookingTime: '15 Min'),
        Recipe(id: 992, title: 'Sup Tomat Klasik', content: '', authorName: '', authorRole: 'USER', image: null, difficulty: 'Sedang', cookingTime: '45 Min'),
        Recipe(id: 993, title: 'Pasta Vongole', content: '', authorName: '', authorRole: 'USER', image: null, difficulty: 'Sedit Sulit', cookingTime: '30 Min'),
        Recipe(id: 994, title: 'Pizza Margherita', content: '', authorName: '', authorRole: 'USER', image: null, difficulty: 'Sedang', cookingTime: '60 Min'),
      ];

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildGridCard(dummyFavorites[index], showFavoriteIcon: true);
            },
            childCount: dummyFavorites.length,
          ),
        ),
      );
    } else {
      // Tab Komentar (List Dummy)
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final comments = [
                {"title": "Salad Musim Semi", "time": "2 jam lalu", "text": "Wah resep dressingnya segar banget! Cocok buat menu diet besok."},
                {"title": "Sup Tomat Klasik", "time": "Kemarin", "text": "Teksturnya pas, anak-anak di rumah pada suka. Makasih resepnya Chef!"},
                {"title": "Salmon Panggang Madu", "time": "3 hari lalu", "text": "Trik panggangnya mantap, ngga lengket di teflon. Bumbu meresap sempurna."},
                {"title": "Pasta Jamur Krimi", "time": "1 minggu lalu", "text": "Saus krimnya creamy banget tapi ngga bikin eneg. Jadi menu favorit keluarga sekarang."},
              ];
              
              if (index >= comments.length) return const SizedBox.shrink();
              
              var comment = comments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Dummy
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE2E8F0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(comment["title"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              Text(comment["time"]!, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment["text"]!,
                            style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: 4,
          ),
        ),
      );
    }
  }

  // Desain Card Grid yang seragam untuk Tab Resepku dan Favorit
  Widget _buildGridCard(Recipe recipe, {required bool showFavoriteIcon}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF2D3748), const Color(0xFF1E293B)]
                : [const Color(0xFFE2E8F0), const Color(0xFF475569)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (recipe.image != null)
              Hero(
                tag: 'recipe-image-${recipe.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'http://192.168.1.5:3000/uploads/${recipe.image}',
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.darken,
                    color: Colors.black.withAlpha(80),
                  ),
                ),
              ),
            if (showFavoriteIcon)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, size: 14, color: Color(0xFF64748B)),
                ),
              ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                recipe.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
