import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _recentSearches = [
    "Truffle pasta",
    "Summer salads",
    "Slow cooker stews",
    "Vegan desserts",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Find Recipes",
          style: TextStyle(
            color: Color(0xFF64748B), // Slate-500
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0), // Slate-200
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Saffron risotto",
                  hintStyle: TextStyle(color: Color(0xFF475569)), // Slate-600
                  prefixIcon: Icon(Icons.search, color: Color(0xFF475569)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Searches Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "RECENT SEARCHES",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text(
                    "Clear All",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent Searches Chips
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _recentSearches.map((search) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Slate-100
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        search,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155), // Slate-700
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _recentSearches.remove(search);
                          });
                        },
                        child: const Icon(Icons.close, size: 14, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Trending Now
            const Text(
              "Trending Now",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            // Editorial Choice (Large Card)
            Container(
              height: 240,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFCBD5E1), // Light slate
                    Color(0xFF1E293B), // Dark slate
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      "EDITORIAL CHOICE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "The Ultimate\nHarvest Salad",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "15 mins • Easy",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Small Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                _buildSmallTrendingCard("Artisan Basil Pesto", "Authentic Italian"),
                _buildSmallTrendingCard("Cloud Donuts", "Baking & Pastry"),
                _buildSmallTrendingCard("Honey Layer Cake", "Russian Classics"),
                _buildSmallTrendingCard("Rainbow Hummus", "Plant Based"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTrendingCard(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
