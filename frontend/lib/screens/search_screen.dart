import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/recipe_model.dart';
import 'home_screen.dart'; // Untuk menggunakan RecipeGridCard
import 'recipe_detail_screen.dart';
import 'public_profile_screen.dart';
import '../services/social_service.dart';

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
  List<dynamic> _userResults = [];
  int _searchType = 0; // 0: Resep, 1: Pengguna
  
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_isFetchingMore && _hasMore && _searchQuery.isNotEmpty) {
          _fetchMore();
        }
      }
    });
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('jwt_token');
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
        _userResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
    });

    try {
      if (_searchType == 0) {
        // Search Recipes
        final res = await http.get(Uri.parse('http://208.76.40.81:3000/api/recipes?search=$query&page=$_page&limit=$_limit'), headers: {'ngrok-skip-browser-warning': 'true'});
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded is List) {
            setState(() {
              _searchResults = decoded.map((e) => Recipe.fromJson(e)).toList();
              _hasMore = false; // Disable pagination if backend doesn't support it yet
            });
          } else {
            final List list = decoded['data'] ?? [];
            setState(() {
              _searchResults = list.map((e) => Recipe.fromJson(e)).toList();
              _hasMore = decoded['pagination']?['hasMore'] ?? false;
            });
          }
        }
      } else {
        if (_token == null) {
          final prefs = await SharedPreferences.getInstance();
          _token = prefs.getString('jwt_token');
        }
        
        final res = await http.get(
          Uri.parse('http://208.76.40.81:3000/api/users/search?q=$query'),
          headers: _token != null ? {'ngrok-skip-browser-warning': 'true', 'Authorization': 'Bearer $_token'} : {'ngrok-skip-browser-warning': 'true'},
        );
        if (res.statusCode == 200) {
          final List list = jsonDecode(res.body);
          setState(() {
            _userResults = list;
            _hasMore = false; // No pagination for users yet
          });
        }
      }
    } catch (e) {
      debugPrint("Error searching: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMore() async {
    if (_searchType == 1) return; // Users don't have pagination yet
    
    setState(() => _isFetchingMore = true);
    _page++;
    try {
      final res = await http.get(Uri.parse('http://208.76.40.81:3000/api/recipes?search=$_searchQuery&page=$_page&limit=$_limit'), headers: {'ngrok-skip-browser-warning': 'true'});
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() {
            _searchResults.addAll(decoded.map((e) => Recipe.fromJson(e)).toList());
            _hasMore = false;
          });
        } else {
          final List list = decoded['data'] ?? [];
          setState(() {
            _searchResults.addAll(list.map((e) => Recipe.fromJson(e)).toList());
            _hasMore = decoded['pagination']?['hasMore'] ?? false;
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
          "Cari Sesuatu",
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
                    hintText: _searchType == 0 ? "Cari resep... misal: Saffron risotto" : "Cari pengguna... misal: suryakhan",
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
                                _userResults = [];
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

          // Tab Type
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchType = 0;
                        });
                        _performSearch(_searchQuery);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _searchType == 0 ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _searchType == 0 ? Colors.transparent : Colors.grey.withAlpha(50)),
                        ),
                        child: Center(
                          child: Text(
                            "Resep",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _searchType == 0 ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchType = 1;
                        });
                        _performSearch(_searchQuery);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _searchType == 1 ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _searchType == 1 ? Colors.transparent : Colors.grey.withAlpha(50)),
                        ),
                        child: Center(
                          child: Text(
                            "Pengguna",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _searchType == 1 ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (showExplore) ...[
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      _searchType == 0 ? "Cari Resep Masakan" : "Cari Akun Pengguna",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
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
            else if (_searchType == 0 && _searchResults.isEmpty)
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
            else if (_searchType == 1 && _userResults.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text("Pengguna tidak ditemukan", style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else if (_searchType == 0)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : (MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2)),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: _searchResults[index]),
                            ),
                          );
                        },
                        child: RecipeGridCard(recipe: _searchResults[index]),
                      );
                    },
                    childCount: _searchResults.length,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = _userResults[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PublicProfileScreen(userId: user['id']),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFFE2E8F0),
                        backgroundImage: user['profileImage'] != null 
                            ? NetworkImage('http://208.76.40.81:3000/uploads/${user['profileImage']}') 
                            : null,
                        child: user['profileImage'] == null 
                            ? const Icon(Icons.person, color: Colors.grey) 
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(user['name'] ?? user['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (user['role'] == 'ADMIN' || user['role'] == 'SUPERADMIN')
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(Icons.verified, color: Colors.blue, size: 14),
                            ),
                        ],
                      ),
                      subtitle: Text("@${user['username']}"),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          try {
                            await SocialService.toggleFollow(user['id']);
                            setState(() {
                              _userResults[index]['isFollowing'] = !(_userResults[index]['isFollowing'] ?? false);
                            });
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(_userResults[index]['isFollowing'] ? "Berhasil mengikuti pengguna!" : "Berhenti mengikuti pengguna."),
                              backgroundColor: _userResults[index]['isFollowing'] ? Colors.green : Colors.orange,
                            ));
                          } catch (e) {
                            if (!context.mounted) return;
                            String errorMessage = "Gagal memproses permintaan.";
                            if (e.toString().contains('Exception:')) {
                              errorMessage = e.toString().split('Exception: ')[1];
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (user['isFollowing'] ?? false) ? Colors.grey.shade300 : const Color(0xFF1E293B),
                          foregroundColor: (user['isFollowing'] ?? false) ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: Text((user['isFollowing'] ?? false) ? "Diikuti" : "Ikuti"),
                      ),
                    );
                  },
                  childCount: _userResults.length,
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
}
