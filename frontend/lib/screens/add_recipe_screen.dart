import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../services/recipe_service.dart';
import 'main_screen.dart'; // Untuk kembali ke Home saat tekan X

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();

  String _selectedCategory = "Makanan";
  final List<String> _categories = ["Makanan", "Minuman", "Dessert"];

  // Dynamic Lists for Ingredients
  final List<Map<String, TextEditingController>> _ingredients = [
    {"qty": TextEditingController(), "name": TextEditingController()},
  ];

  // Dynamic Lists for Steps
  final List<TextEditingController> _steps = [TextEditingController()];

  XFile? _coverImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  Future<void> _pickCoverImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _coverImage = picked;
      });
    }
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add({
        "qty": TextEditingController(),
        "name": TextEditingController(),
      });
    });
  }

  void _removeIngredientRow(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients.removeAt(index);
      });
    }
  }

  void _addStepRow() {
    setState(() {
      _steps.add(TextEditingController());
    });
  }

  void _removeStepRow(int index) {
    if (_steps.length > 1) {
      setState(() {
        _steps.removeAt(index);
      });
    }
  }

  void _handlePost() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul tidak boleh kosong!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Menyusun data JSON untuk kolom 'content'
    List<Map<String, String>> ingredientsData = _ingredients.map((ing) {
      return {"qty": ing["qty"]!.text, "name": ing["name"]!.text};
    }).toList();

    List<String> stepsData = _steps.map((step) => step.text).toList();

    Map<String, dynamic> contentData = {
      "description": _descController.text,
      "ingredients": ingredientsData,
      "steps": stepsData,
    };

    String contentJson = jsonEncode(contentData);

    // API Post (Nanti backend akan menerima file image via multipart)
    bool success = await RecipeService.createRecipe(
      title: _titleController.text,
      content: contentJson,
      categoryId:
          1, // Harusnya sesuai _selectedCategory, tapi backend butuh int. Asumsi Nasi = 1
      difficulty: "Easy", // Default
      cookingTime: _prepTimeController.text.isNotEmpty
          ? _prepTimeController.text
          : "30 min",
      imagePath: _coverImage?.path, // Path lokal untuk diunggah (web/mobile)
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Resep berhasil diposting!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal memposting resep.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
        title: Text(
          "New Recipe",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handlePost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    "Post",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ), // Membatasi lebar agar rapi di Web/Desktop
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Photo Placeholder
                GestureDetector(
                  onTap: _pickCoverImage,
                  child: AspectRatio(
                    aspectRatio:
                        16 /
                        9, // Rasio standar cover foto (Landscape) yang cantik di HP maupun Web
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(
                          0xFFE2E8F0,
                        ), // Warna solid abu-abu kebiruan
                        image: _coverImage != null
                            ? DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(_coverImage!.path)
                                    : FileImage(File(_coverImage!.path))
                                          as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _coverImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF4A4A4A),
                                  size: 50,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Add a cover photo",
                                  style: TextStyle(
                                    color: Color(0xFF4A4A4A),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recipe Title
                _buildSectionTitle("RECIPE TITLE"),
                const SizedBox(height: 8),
                _buildTextField(
                  "e.g. Saffron Infused Creamy Risotto",
                  _titleController,
                ),
                const SizedBox(height: 24),

                // Short Description
                _buildSectionTitle("SHORT DESCRIPTION"),
                const SizedBox(height: 8),
                _buildTextField(
                  "Share the story behind this dish...",
                  _descController,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),

                // Category
                _buildSectionTitle("CATEGORY"),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _categories.map((cat) {
                    bool isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 48),

                // Ingredients
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ingredients",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    GestureDetector(
                      onTap: _addIngredientRow,
                      child: Text(
                        "+ Add Item",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._ingredients.asMap().entries.map((entry) {
                  int index = entry.key;
                  var ing = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildTextField("Quantity", ing["qty"]!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            "Ingredient name...",
                            ing["name"]!,
                          ),
                        ),
                        if (_ingredients.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeIngredientRow(index),
                          ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 48),

                // Cooking Steps
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cooking Steps",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    GestureDetector(
                      onTap: _addStepRow,
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle,
                            size: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Add Step",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFF64748B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                "Describe the step...",
                                controller,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 8),
                              if (_steps.length > 1)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeStepRow(index),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 48),

                // Prep Time & Servings
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        "PREP TIME",
                        Icons.access_time,
                        "15 min",
                        _prepTimeController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoBox(
                        "SERVINGS",
                        Icons.people,
                        "2 people",
                        _servingsController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Spasi bawah
              ],
            ), // Close Column
          ), // Close ConstrainedBox
        ), // Close Center
      ), // Close SingleChildScrollView
    ); // Close Scaffold
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : const Color(0xFF4A4A4A),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(
    String title,
    IconData icon,
    String hint,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
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
