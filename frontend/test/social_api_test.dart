import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('Social API Mock Tests', () {
    test('Should parse Notification list correctly', () {
      const jsonResponse = '''
      [
        {
          "id": 1,
          "message": "[UPDATE APK] Pengumuman baru",
          "type": "SUPERADMIN_ANNOUNCEMENT",
          "isRead": false
        },
        {
          "id": 2,
          "message": "User memfollow anda",
          "type": "FOLLOW",
          "isRead": true
        }
      ]
      ''';

      final List<dynamic> data = jsonDecode(jsonResponse);

      expect(data.length, 2);
      expect(data[0]['isRead'], false);
      expect(data[0]['message'], contains('[UPDATE APK]'));
      expect(data[1]['type'], 'FOLLOW');
    });
  });
}
