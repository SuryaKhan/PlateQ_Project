import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _currentUsername;
  bool _isFavorited = false;
  
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final comments = await RecipeService.fetchComments(widget.recipe.id);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUsername = prefs.getString('username');
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    final text = _commentController.text.trim();
    _commentController.clear();
    FocusScope.of(context).unfocus();

    // Optimistic UI update
    final tempComment = {
      "text": text,
      "user": {"name": _currentUsername ?? "Kamu", "profileImage": null},
      "createdAt": DateTime.now().toIso8601String()
    };
    setState(() {
      _comments.insert(0, tempComment);
    });

    // Send to backend
    bool success = await RecipeService.addComment(widget.recipe.id, text);
      if (success) {
        _fetchComments(); // Refresh with real data
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim komentar.")));
        // Rollback optimistic update
        setState(() {
          _comments.removeAt(0);
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    // Parsing content JSON if available
    String description = widget.recipe.content;
    List<Map<String, dynamic>> ingredients = [];
    List<String> steps = [];

    try {
      final decoded = jsonDecode(widget.recipe.content);
      if (decoded is Map<String, dynamic>) {
        description = decoded['description'] ?? widget.recipe.content;
        if (decoded['ingredients'] != null) {
          ingredients = List<Map<String, dynamic>>.from(decoded['ingredients']);
        }
        if (decoded['steps'] != null) {
          steps = List<String>.from(decoded['steps']);
        }
      }
    } catch (e) {
      ingredients = [
        {"name": "Nasi Putih", "qty": "2 porsi"},
        {"name": "Bawang Merah", "qty": "3 siung"},
        {"name": "Cabai Rawit", "qty": "4 buah"},
        {"name": "Kecap Manis", "qty": "2 sdm"},
      ];
      steps = [
        "Siapkan bumbu halus.",
        "Tumis rempah hingga harum.",
        "Masukan nasi putih dan kecap."
      ];
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SafeArea(
            child: Row(
              children: [
                CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade300),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      decoration: const InputDecoration(
                        hintText: "Tulis komentar...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // --- 1. Konten Scrollable Utama ---
          SingleChildScrollView(
            child: Stack(
              children: [
                // Gambar Background (Posisi Paling Belakang)
                Container(
                  height: 320,
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0),
                  child: widget.recipe.image != null
                      ? Hero(
                          tag: 'recipe-image-${widget.recipe.id}',
                          child: Image.network(
                            'http://192.168.101.127:3000/uploads/${widget.recipe.image}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 60),
                          ),
                        )
                      : null,
                ),

                // Card Konten Putih (Overlap ke atas gambar)
                Container(
                  margin: const EdgeInsets.only(top: 280),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul & Deskripsi
                        Padding(
                          padding: const EdgeInsets.only(right: 60), // Beri ruang agar teks tidak nabrak tombol love
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.recipe.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.grey.shade300,
                                    child: const Icon(Icons.person, size: 16, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.recipe.authorName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (widget.recipe.authorRole == 'ADMIN' || widget.recipe.authorRole == 'SUPERADMIN')
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4.0),
                                      child: Icon(Icons.verified, color: Colors.blue, size: 14),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                description.isNotEmpty ? description : "Resep aromatik dengan bumbu pilihan.",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                                // Tombol Sosial (Follow & DM)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text("Berhasil mengikuti pengguna! Notifikasi telah dikirim."),
                                            backgroundColor: Colors.green,
                                          ));
                                        },
                                        icon: const Icon(Icons.person_add, size: 16),
                                        label: const Text("Ikuti", style: TextStyle(fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1E293B),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context, 
                                            builder: (_) => AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              title: const Text("Fitur Coming Soon 🚀", style: TextStyle(fontWeight: FontWeight.bold)),
                                              content: const Text("Fitur Kirim Pesan (DM) sedang dalam pengembangan.\n\nSaat ini diskusi hanya bisa dilakukan di kolom komentar resep ya!"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context), 
                                                  child: const Text("Siap!", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))
                                                )
                                              ],
                                            )
                                          );
                                        },
                                        icon: const Icon(Icons.mail_outline, size: 16),
                                        label: const Text("Pesan", style: TextStyle(fontWeight: FontWeight.bold)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                                          side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info Boxes
                        Row(
                          children: [
                            Expanded(child: _buildInfoPill(Icons.access_time, "PREP TIME", widget.recipe.cookingTime)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInfoPill(Icons.people_outline, "SERVINGS", "2 people")),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoPill(Icons.restaurant, "DIFFICULTY", widget.recipe.difficulty),
                        const SizedBox(height: 32),

                        // Ingredients
                        const Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            children: ingredients.asMap().entries.map((entry) {
                              int idx = entry.key;
                              var ing = entry.value;
                              return Column(
                                children: [
                                  _buildIngredientRow(ing['name'] ?? '', ing['qty'] ?? ''),
                                  if (idx != ingredients.length - 1) const Divider(),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Cooking Steps
                        Text("Cara Memasak", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 16),
                        ...steps.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildStepRow("${entry.key + 1}", "Langkah ${entry.key + 1}", entry.value),
                          );
                        }),
                        const SizedBox(height: 32),

                        // Cooksnaps (I Made This!)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("Foto Recook", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                const SizedBox(width: 4),
                                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Segera Hadir: Fitur Upload Foto Recook!")));
                              },
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: const Text("Aku Buat Ini!"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37), // Emas elegan
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3, // Dummy
                            itemBuilder: (context, index) {
                              return Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.grey.shade300,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 5)],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: Image.network(
                                        'https://picsum.photos/200?random=$index', // Dummy gambar acak
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    const Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.person, size: 16, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Komentar
                        Text("Komentar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 16),
                        ..._comments.reversed.map((c) {
                          final user = c['user'] ?? {};
                          final name = user['name'] ?? 'Pengguna';
                          final text = c['text'] ?? '';
                          final timeStr = c['createdAt'] ?? '';
                          final time = timeStr.length > 10 ? timeStr.substring(0, 10) : 'Baru saja';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildCommentRow(name, time, text),
                          );
                        }),
                        const SizedBox(height: 100), // Spasi untuk bottom sheet
                      ],
                    ),
                  ),
                ),

                // Tombol Favorite Melayang (Terpisah dari container putih agar tidak kepotong)
                Positioned(
                  top: 255, // Setengah di gambar (280), setengah di putih
                  right: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B), // Biru dongker
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited ? Colors.redAccent : Colors.white,
                      ),
                      onPressed: () async {
                        await RecipeService.toggleBookmark(widget.recipe.id);
                        if (!context.mounted) return;
                        setState(() {
                          _isFavorited = !_isFavorited;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_isFavorited ? "Ditambahkan ke Favorit!" : "Dihapus dari Favorit"))
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. Custom AppBar Transparan ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.recipe.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          shadows: [Shadow(color: Colors.white, blurRadius: 15)],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_currentUsername != null && widget.recipe.authorName == _currentUsername)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditRecipeScreen(recipe: widget.recipe),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIngredientRow(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          Text(amount, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStepRow(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle),
          child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: Colors.grey, height: 1.5)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCommentRow(String name, String time, String comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 16, backgroundColor: Colors.grey.shade300),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(width: 8),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(200), fontSize: 14, height: 1.4)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _commentController.text = "@$name ";
                  });
                  _commentFocusNode.requestFocus();
                },
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text("Balas", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
