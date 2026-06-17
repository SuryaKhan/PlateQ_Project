import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/recipe_model.dart';
import 'recipe_detail_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final data = await AuthService.getPublicProfile(widget.userId);
    setState(() {
      _profileData = data;
      _isLoading = false;
    });
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
        appBar: AppBar(title: const Text("Profil")),
        body: const Center(child: Text("Pengguna tidak ditemukan")),
      );
    }

    final user = _profileData!;
    final bool isAdmin = user['role'] == 'ADMIN' || user['role'] == 'SUPERADMIN';

    // Parse recipes
    final List<dynamic> recipesRaw = user['recipes'] ?? [];
    final List<Recipe> recipes = recipesRaw.map((r) => Recipe.fromJson(r)).toList();

    int columns = MediaQuery.of(context).size.width > 1200 ? 5 : (MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        title: Text(
          "Profil Pengguna",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
            slivers: [
              // Header Profil
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFFE2E8F0),
                        backgroundImage: user['profileImage'] != null
                            ? NetworkImage('https://publisher-neurotic-affluent.ngrok-free.dev/uploads/${user['profileImage']}')
                            : null,
                        child: user['profileImage'] == null
                            ? const Icon(Icons.person, size: 55, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user['name'] ?? 'User',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (isAdmin)
                            const Padding(
                              padding: EdgeInsets.only(left: 6.0),
                              child: Icon(Icons.verified, color: Colors.blue, size: 20),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user['username']}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem("Resep", recipes.length.toString()),
                          const SizedBox(width: 20),
                          _buildStatItem("Pengikut", user['followersCount'].toString()),
                          const SizedBox(width: 20),
                          _buildStatItem("Mengikuti", user['followingCount'].toString()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (user['bio'] != null && user['bio'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            user['bio'],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        "Resep oleh ${user['name']}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Grid Resep
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: recipes.isEmpty
                  ? const SliverToBoxAdapter(child: Center(child: Text("Belum ada resep yang dibuat.")))
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildGridCard(recipes[index]);
                        },
                        childCount: recipes.length,
                      ),
                    ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGridCard(Recipe recipe) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)));
        _loadProfile();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: recipe.image != null
                        ? Image.network(
                            'https://publisher-neurotic-affluent.ngrok-free.dev/uploads/${recipe.image}',
                            fit: BoxFit.cover,
                          )
                        : Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
