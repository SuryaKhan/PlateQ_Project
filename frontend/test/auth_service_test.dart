import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService Tests', () {
    test('Token is null initially', () async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      expect(token, isNull);
    });

    test('Logout clears the token', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'dummy_token');
      
      await AuthService.logout();
      
      final tokenAfterLogout = prefs.getString('jwt_token');
      expect(tokenAfterLogout, isNull);
    });
  });
}
