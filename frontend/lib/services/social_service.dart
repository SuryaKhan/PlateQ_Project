import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SocialService {
  static const String baseUrl = 'http://208.76.40.81:3000/api/social';

  static Future<Map<String, dynamic>> toggleFollow(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/follow/$userId'),
      headers: {'ngrok-skip-browser-warning': 'true', 
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to toggle follow');
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowers(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/followers'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getFollowing(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/following'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }
}
