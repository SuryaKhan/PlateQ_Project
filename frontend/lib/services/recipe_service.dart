import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart'; // Panggil cetakan yang tadi dibikin

class RecipeService {
  static const String baseUrl = 'http://192.168.1.5:3000/api/recipes';

  // Fungsi buat ngambil semua data resep (GET)
  static Future<List<Recipe>> fetchRecipes({int? authorId}) async {
    try {
      String url = baseUrl;
      if (authorId != null) {
        url += '?authorId=$authorId';
      }
      // 1. Buka brankas HP buat ngambil Token JWT
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // 2. Tembak API dan bawa Token-nya di bagian "Headers"
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Ini kunci masuknya!
        },
      );

      // 3. Kalau sukses masuk (200 OK), ubah JSON jadi List<Recipe>
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((json) => Recipe.fromJson(json)).toList();
        } else {
          debugPrint("❌ Error Backend: Respons bukan array/list! Isi: $decoded");
          return [];
        }
      } else {
        debugPrint("Gagal ambil resep. Status: ${response.statusCode}");
        debugPrint("Pesan: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Error Fetch Resep: $e");
      return [];
    }
  }

  // Fungsi buat bikin resep baru (POST)
  static Future<bool> createRecipe({
    required String title,
    required String content,
    required int categoryId,
    required String difficulty,
    required String cookingTime,
    String? imagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['categoryId'] = categoryId.toString();
      request.fields['difficulty'] = difficulty;
      request.fields['cookingTime'] = cookingTime;

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint("Gagal buat resep. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Error Create Resep: $e");
      return false;
    }
  }
}
