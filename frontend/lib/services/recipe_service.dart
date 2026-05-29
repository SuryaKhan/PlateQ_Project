import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart'; // Panggil cetakan yang tadi dibikin

class RecipeService {
  static const String baseUrl = 'http://localhost:3000/api/recipes';

  // Fungsi buat ngambil semua data resep (GET)
  static Future<List<Recipe>> fetchRecipes() async {
    try {
      // 1. Buka brankas HP buat ngambil Token JWT
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // 2. Tembak API dan bawa Token-nya di bagian "Headers"
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Ini kunci masuknya!
        },
      );

      // 3. Kalau sukses masuk (200 OK), ubah JSON jadi List<Recipe>
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Recipe.fromJson(data)).toList();
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
}
