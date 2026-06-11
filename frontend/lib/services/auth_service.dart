import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Base URL untuk Auth
  static const String authUrl = 'http://192.168.1.5:3000/api/auth';
  // Base URL untuk User Profile
  static const String userUrl = 'http://192.168.1.5:3000/api/users';

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

        // Simpan token ke brankas lokal (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

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
  // Dipakai saat klik "Complete Profile" atau "Start Exploring"
  static Future<bool> updateProfile(String name, String username, String bio, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint("❌ Token tidak ditemukan! Login dulu bro.");
        return false;
      }

      final response = await http.put(
        Uri.parse('$userUrl/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Mengirim tiket masuk ke Backend
        },
        body: jsonEncode({
          'name': name,
          'username': username,
          'bio': bio,
          'email': email,
        }),
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
  // 3.5 FUNGSI GET PROFIL
  // ==========================================
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$userUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error Pas Get Profil: $e");
      return null;
    }
  }

  // ==========================================
  // 4. FUNGSI LOGOUT (KELUAR)
  // ==========================================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    debugPrint("--- LOGOUT BERHASIL ---");
  }
  // ==========================================
  // 5. FUNGSI LUPA PASSWORD (FORGOT PASSWORD)
  // ==========================================
  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      debugPrint("--- FORGOT PASSWORD LOG ---");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Error Pas Forgot Password: $e");
      return false;
    }
  }

  // ==========================================
  // 6. FUNGSI GANTI PASSWORD (CHANGE PASSWORD)
  // ==========================================
  static Future<bool> changePassword(String email, String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      debugPrint("--- CHANGE PASSWORD LOG ---");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Error Pas Change Password: $e");
      return false;
    }
  }
}
