import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('Admin API Mock Tests', () {
    test('Should parse Admin Dashboard Stats JSON correctly', () {
      const jsonResponse = '''
      {
        "totalUsers": 150,
        "totalRecipes": 340,
        "totalComments": 1200
      }
      ''';

      final Map<String, dynamic> data = jsonDecode(jsonResponse);

      expect(data['totalUsers'], 150);
      expect(data['totalRecipes'], 340);
      expect(data['totalComments'], 1200);
    });

    test('Should validate announcement payload', () {
      final payload = {
        "title": "Update V2",
        "content": "New UI Features",
        "category": "UPDATE_APK"
      };

      expect(payload.containsKey('title'), isTrue);
      expect(payload.containsKey('category'), isTrue);
      expect(payload['category'], 'UPDATE_APK');
    });
  });
}
