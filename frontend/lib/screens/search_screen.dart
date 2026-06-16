import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/recipe_model.dart';
import 'home_screen.dart'; // Untuk menggunakan RecipeGridCard

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  final List<String> _recentSearches = [
    "Truffle pasta",
    "Summer salads",
    "Slow cooker stews",
    "Vegan desserts",
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_isFetchingMore && _hasMore && _searchQuery.isNotEmpty) {
          _fetchMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
    });

    try {
      final res = await http.get(Uri.parse('http://192.168.101.127:3000/api/recipes?search=$query&page=$_page&limit=$_limit'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['data'] ?? [];
        setState(() {
          _searchResults = list.map((e) => Recipe.fromJson(e)).toList();
          _hasMore = data['pagination']['hasMore'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Error searching: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMore() async {
    setState(() => _isFetchingMore = true);
    _page++;
    try {
      final res = await http.get(Uri.parse('http://192.168.101.127:3000/api/recipes?search=$_searchQuery&page=$_page&limit=$_limit'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['data'] ?? [];
        if (mounted) {
          setState(() {
            _searchResults.addAll(list.map((e) => Recipe.fromJson(e)).toList());
            _hasMore = data['pagination']['hasMore'] ?? false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching more: $e");
    } finally {
      if (mounted) setState(() => _isFetchingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showExplore = _searchQuery.isEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ) : const SizedBox(),
        title: const Text(
          "Find Recipes",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _performSearch(val);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Saffron risotto",
                    hintStyle: const TextStyle(color: Color(0xFF475569)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF475569)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF475569)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: const TextStyle(color: Color(0xFF1E293B)),
                ),
              ),
            ),
          ),

          if (showExplore) ...[
            // Explore UI
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                search,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
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
                    // Editorial Choice
                    Container(
                      height: 240,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFCBD5E1), Color(0xFF1E293B)],
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
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: 1),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "The Ultimate\nHarvest Salad",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "15 mins • Easy",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Search Results UI
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_searchResults.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text("Tidak ada resep yang cocok", style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text("Coba gunakan kata kunci lain.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return RecipeGridCard(recipe: _searchResults[index]);
                    },
                    childCount: _searchResults.length,
                  ),
                ),
              ),

            if (_isFetchingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ],
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
