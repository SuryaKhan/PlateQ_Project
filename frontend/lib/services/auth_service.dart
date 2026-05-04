import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String authUrl = 'http://localhost:3000/api/auth';
  static const String userUrl = 'http://localhost:3000/api/users';

  // Inisialisasi Brankas
  static const _storage = FlutterSecureStorage();

  // ==========================================
  // 1. FUNGSI REGISTER (DAFTAR)
  // ==========================================
  static Future<bool> register(
    String email,
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      debugPrint("--- REGISTER LOG ---");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ Error Pas Register: $e");
      return false;
    }
  }

  // ==========================================
  // 2. FUNGSI LOGIN (MASUK)
  // ==========================================
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      debugPrint("--- LOGIN LOG ---");
      debugPrint("Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];

        // Simpan token ke brankas lokal (Secure Storage)
        await _storage.write(key: 'jwt_token', value: token);

        return true;
      } else {
        debugPrint("Gagal Login: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error Pas Login: $e");
      return false;
    }
  }

  // ==========================================
  // 3. FUNGSI UPDATE PROFIL (TASTE PROFILE)
  // ==========================================
  static Future<bool> updateProfile(String name, String bio) async {
    try {
      // Ambil token dari brankas
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        debugPrint("❌ Token tidak ditemukan! Login dulu bro.");
        return false;
      }

      final response = await http.put(
        Uri.parse('$userUrl/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'bio': bio}),
      );

      debugPrint("--- UPDATE PROFILE LOG ---");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Error Pas Update Profil: $e");
      return false;
    }
  }

  // ==========================================
  // 4. FUNGSI LOGOUT (KELUAR)
  // ==========================================
  static Future<void> logout() async {
    // Hapus token dari brankas
    await _storage.delete(key: 'jwt_token');
    debugPrint("--- LOGOUT BERHASIL ---");
  }
}
