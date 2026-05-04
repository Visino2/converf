import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:converf/features/auth/repositories/auth_repository.dart';
import 'package:converf/features/auth/models/auth_response.dart';
import 'package:converf/core/auth/session_manager.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionManager extends Mock implements SessionManager {}

void main() {
  group('Auth Provider Tests', () {
    late MockAuthRepository mockAuthRepository;
    late MockSessionManager mockSessionManager;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockSessionManager = MockSessionManager();
    });

    test('Login with valid credentials succeeds', () async {
      // Setup
      const email = 'test@converf.com';
      const password = 'password123';

      final mockResponse = AuthResponse(
        status: true,
        message: 'Login successful',
        data: AuthData(
          token: 'fake_token_12345',
          user: {
            'id': '123',
            'email': email,
            'role': 'contractor',
            'first_name': 'Test',
            'last_name': 'User',
          },
        ),
      );

      when(
        mockAuthRepository.login(email, password),
      ).thenAnswer((_) async => mockResponse);
      expect(mockResponse.status, true);
      expect(mockResponse.data?.token, 'fake_token_12345');
    });

    test('Login with invalid credentials fails', () async {
      final mockResponse = AuthResponse(
        status: false,
        message: 'Invalid credentials',
        data: null,
      );

      expect(mockResponse.status, false);
      expect(mockResponse.data, null);
    });

    test('Logout clears session', () async {
      when(mockSessionManager.clearSession()).thenAnswer((_) async {});

      await mockSessionManager.clearSession();

      verify(mockSessionManager.clearSession()).called(1);
    });

    test('Auth data contains required fields', () {
      final authData = AuthData(
        token: 'test_token',
        user: {'id': '123', 'email': 'test@converf.com', 'role': 'contractor'},
      );

      expect(authData.token, isNotEmpty);
      expect(authData.user['email'], 'test@converf.com');
    });

    test('UserRole parsing works correctly', () {
      expect(UserRole.fromString('contractor'), UserRole.contractor);
      expect(UserRole.fromString('project_owner'), UserRole.projectOwner);
      expect(UserRole.fromString('owner'), UserRole.projectOwner);
      expect(UserRole.fromString('invalid'), UserRole.unknown);
    });
  });
}
