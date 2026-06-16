import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SocialService {
  static const String baseUrl = 'http://192.168.101.127:3000/api/social';

  static Future<Map<String, dynamic>> toggleFollow(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/follow/$userId'),
      headers: {
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
}
