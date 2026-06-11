import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../models/recipe_model.dart';
import 'search_screen.dart';
import '../screens/notification_screen.dart';
import '../theme/theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recipe>> _recipesFuture;
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Semua', 'Nasi', 'Mie', 'Minuman'];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  void _fetchRecipes() {
    setState(() {
      _recipesFuture = RecipeService.fetchRecipes();
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
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
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
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                          },
                        ),
                      ),
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

              // 2. Search Bar
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    enabled: false, // Matikan input karena diklik navigasi
                    decoration: InputDecoration(
                      hintText: 'Mau masak apa hari ini?',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
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
                        // Nanti tambahkan filter ke fetchRecipes berdasarkan kategori
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
                              color: isSelected ? Colors.white : Colors.black54,
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

                    final recipes = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: () async { _fetchRecipes(); },
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75, // Mengatur proporsi tinggi vs lebar kartu
                        ),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return RecipeGridCard(recipe: recipes[index]);
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
                              'http://192.168.1.5:3000/uploads/${recipe.image}',
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
          // Bagian melengkung khas mockup
          Positioned(
            bottom: 65, // Sesuaikan angka ini agar pas dengan desain mockup (tengah-tengah transisi gambar)
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
