import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <-- Panggil Brankas Besi
import '../models/recipe_model.dart';

class RecipeService {
  static const String baseUrl = 'http://localhost:3000/api/recipes';

  // Inisialisasi Brankas
  static const _storage = FlutterSecureStorage();

  // Fungsi buat ngambil semua data resep (GET)
  static Future<List<Recipe>> fetchRecipes() async {
    try {
      // 1. Buka brankas HP buat ngambil Token JWT
      final token = await _storage.read(key: 'jwt_token');

      // Siapkan headers. Kalau token ada, bawa tokennya.
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token'; // Ini kunci masuknya!
      }

      // 2. Tembak API
      final response = await http.get(Uri.parse(baseUrl), headers: headers);

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
      debugPrint("❌ Error Fetch Resep: $e");
      return [];
    }
  }
}
