import 'package:flutter/material.dart';

// Halaman Utama: Explore Recipes
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Temporary dummy data based on the mockup.
  // In a real app, this would come from an API call to your Node.js backend (Recipe model).
  final List<Map<String, dynamic>> dummyRecipes = [
    {
      'title': 'Classic Spaghetti Carbonara',
      'author': 'Chef Isabella',
      'difficulty': 'Medium',
      'time': '45 min',
      'rating': 4.8,
      'reviews': 128,
      // Temporarily null, we will handle placeholder images later.
      'imageAsset': null,
    },
    {
      'title': 'Healthy Quinoa Salad',
      'author': 'Chef Marcus',
      'difficulty': 'Easy',
      'time': '20 min',
      'rating': 4.5,
      'reviews': 95,
      'imageAsset': null,
    },
    {
      'title': 'Gourmet Beef Burger',
      'author': 'Chef David',
      'difficulty': 'Hard',
      'time': '60 min',
      'rating': 5.0,
      'reviews': 210,
      'imageAsset': null,
    },
    {
      'title': 'Indonesian Nasi Goreng',
      'author': 'Surya PlateQ',
      'difficulty': 'Easy',
      'time': '30 min',
      'rating': 4.9,
      'reviews': 150,
      'imageAsset': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background bersih sesuai mockup
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50), // Margin atas agar di bawah status bar
            // 1. Judul Halaman: Explore
            const Text(
              'Explore',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Search Bar (Kotak Pencarian)
            TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes, ingredients...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey, // Warna abu-abu muda
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none, // Tanpa border hitam
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Daftar Resep (Scrollable List)
            Expanded(
              child: ListView.builder(
                itemCount: dummyRecipes.length,
                padding: const EdgeInsets.only(
                  bottom: 20.0,
                ), // Padding di bawah list
                itemBuilder: (context, index) {
                  final recipe = dummyRecipes[index];
                  // Panggil widget khusus untuk menampilkan kartu resep
                  return RecipeListCard(recipe: recipe);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Khusus untuk Menampilkan Kartu Resep (Recipe Item)
class RecipeListCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeListCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Bayangan halus sesuai mockup
      margin: const EdgeInsets.only(bottom: 16.0), // Jarak antar kartu
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Sudut membulat kartu
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Jarak di dalam kartu
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text and image at the top
          children: [
            // 1. Recipe Image Placeholder (Kotak Gambar)
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey, // Warna placeholder jika gambar kosong
                borderRadius: BorderRadius.circular(
                  12.0,
                ), // Sudut membulat gambar
              ),
              child: const Center(
                // Sementara pakai ikon piring/sendok dulu.
                // Nanti kita ganti Image.network() pas udah narik data backend
                child: Icon(
                  Icons.restaurant_menu,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 16), // Jarak antara gambar dan teks
            // 2. Bagian Kanan: Konten Teks (Expanded agar memenuhi sisa ruang)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Resep & Ikon Heart (Hati) Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2, // Maksimal 2 baris agar rapi
                          overflow: TextOverflow
                              .ellipsis, // Tambahkan ... jika judul terlalu panjang
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Ikon Hati/Bookmark (Sementara tidak bisa diklik)
                      const Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Penulis (Author)
                  Text(
                    'by ${recipe['author']}',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 6),

                  // Kesulitan & Waktu Row (Medium • 45 min)
                  Text(
                    '${recipe['difficulty']} • ${recipe['time']}',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 6),

                  // Rating & Reviews Row (Stars + Rating)
                  Row(
                    children: [
                      // Sederhanakan tampilan bintang (satu bintang kuning)
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe['rating']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${recipe['reviews']})',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
