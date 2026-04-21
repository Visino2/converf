import 'package:flutter_test/flutter_test.dart';
import 'package:converf/features/auth/models/auth_response.dart';

void main() {
  group('Auth Response Parsing Tests', () {
    test('AuthResponse parses successful login response', () {
      final jsonResponse = {
        'status': true,
        'message': 'Login successful',
        'data': {
          'token': 'test_token_xyz',
          'user': {
            'id': '123',
            'email': 'test@converf.com',
            'role': 'contractor',
            'first_name': 'Test',
            'last_name': 'User',
          },
        },
        'errors': null,
      };

      final response = AuthResponse.fromJson(jsonResponse);

      expect(response.status, true);
      expect(response.message, 'Login successful');
      expect(response.data?.token, 'test_token_xyz');
      expect(response.data?.user['email'], 'test@converf.com');
    });

    test('AuthResponse parses failed login response', () {
      final jsonResponse = {
        'status': false,
        'message': 'Invalid credentials',
        'data': null,
        'errors': {
          'credentials': ['Email or password is incorrect'],
        },
      };

      final response = AuthResponse.fromJson(jsonResponse);

      expect(response.status, false);
      expect(response.message, 'Invalid credentials');
      expect(response.data, null);
    });

    test('AuthResponse handles missing user data gracefully', () {
      final jsonResponse = {
        'status': true,
        'message': 'Success',
        'data': {'token': 'token_123', 'user': <String, dynamic>{}},
        'errors': null,
      };

      final response = AuthResponse.fromJson(jsonResponse);

      expect(response.status, true);
      expect(response.data?.token, 'token_123');
    });

    test('UserRole parsing from different formats', () {
      expect(UserRole.fromString('contractor'), UserRole.contractor);
      expect(UserRole.fromString('project_owner'), UserRole.projectOwner);
      expect(UserRole.fromString('owner'), UserRole.projectOwner);
      expect(UserRole.fromString('product_owner'), UserRole.projectOwner);
      expect(UserRole.fromString('unknown_role'), UserRole.unknown);
      expect(UserRole.fromString(null), UserRole.unknown);
      expect(UserRole.fromString(''), UserRole.unknown);
    });

    test('AuthData copyWith preserves token', () {
      final authData = AuthData(
        token: 'original_token',
        user: {'id': '123', 'email': 'test@converf.com'},
      );

      final updated = authData.copyWith(
        user: {'id': '123', 'email': 'new@converf.com'},
      );

      expect(updated.token, 'original_token');
      expect(updated.user['email'], 'new@converf.com');
    });

    test('AuthData copyWith updates token', () {
      final authData = AuthData(token: 'old_token', user: {'id': '123'});

      final updated = authData.copyWith(token: 'new_token');

      expect(updated.token, 'new_token');
      expect(updated.user['id'], '123');
    });
  });
}
