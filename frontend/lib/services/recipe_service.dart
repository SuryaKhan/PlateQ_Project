import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart'; // Panggil cetakan yang tadi dibikin

class RecipeService {
  static const String baseUrl = 'http://192.168.101.133:3000/api/recipes';

  // Fungsi buat ngambil semua data resep (GET)
  static Future<List<Recipe>> fetchRecipes({int? authorId, int? categoryId}) async {
    try {
      String url = baseUrl;
      List<String> queryParams = [];
      if (authorId != null) queryParams.add('authorId=$authorId');
      if (categoryId != null) queryParams.add('categoryId=$categoryId');
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      // 1. Buka brankas HP buat ngambil Token JWT
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // 2. Tembak API dan bawa Token-nya di bagian "Headers"
      final response = await http.get(
        Uri.parse(url),
        headers: {'ngrok-skip-browser-warning': 'true', 
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

  // Fungsi buat edit resep (PUT)
  static Future<bool> updateRecipe({
    required int id,
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

      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['categoryId'] = categoryId.toString();
      request.fields['difficulty'] = difficulty;
      request.fields['cookingTime'] = cookingTime;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Gagal update resep. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Error Update Resep: $e");
      return false;
    }
  } // <-- Tutup updateRecipe()

  static Future<bool> deleteRecipe(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'ngrok-skip-browser-warning': 'true', 
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Gagal hapus resep. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Error Delete Resep: $e");
      return false;
    }
  }

  // 6. Ambil Komentar
  static Future<List<Map<String, dynamic>>> fetchComments(int recipeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$recipeId/comments'), headers: {'ngrok-skip-browser-warning': 'true'});
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint("Error Fetch Comments: $e");
      return [];
    }
  }

  // 7. Tambah Komentar
  static Future<bool> addComment(int recipeId, String text, {int? parentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final Map<String, dynamic> bodyData = {'text': text};
      if (parentId != null) {
        bodyData['parentId'] = parentId;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$recipeId/comments'),
        headers: {'ngrok-skip-browser-warning': 'true', 
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error Add Comment: $e");
      return false;
    }
  }

  // 7.5 Hapus Komentar
  static Future<bool> deleteComment(int recipeId, int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/$recipeId/comments/$commentId'),
        headers: {'ngrok-skip-browser-warning': 'true', 
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Delete Comment: $e");
      return false;
    }
  }

  static Future<bool?> toggleBookmark(int recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('$baseUrl/$recipeId/bookmark'),
        headers: {'ngrok-skip-browser-warning': 'true', 
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['bookmarked'] == true; // Backend returns this
      }
      return null;
    } catch (e) {
      debugPrint("Error Toggle Bookmark: $e");
      return null;
    }
  }
}
