import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/auth_response.dart';
import '../models/contractor_register_request.dart';
import '../models/product_owner_register_request.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(ApiClient(dio));
});

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<AuthResponse> registerContractor(ContractorRegisterRequest request) async {
    final response = await _apiClient.post(
      '/api/v1/auth/register/contractor',
      data: request.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> registerOwner(ProductOwnerRegisterRequest request) async {
    final response = await _apiClient.post(
      '/api/v1/auth/register/owner',
      data: request.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> logout() async {
    final response = await _apiClient.post('/api/v1/auth/logout');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> forgotPassword(String email) async {
    final response = await _apiClient.post(
      '/api/v1/auth/forgot-password',
      data: {'email': email},
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/reset-password',
      data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> acceptInvitation({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/team/invitations/accept',
      data: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }
}
