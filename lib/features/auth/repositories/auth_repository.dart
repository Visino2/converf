import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/auth_response.dart';
import '../models/contractor_register_request.dart';
import '../models/email_verification_status.dart';
import '../models/product_owner_register_request.dart';
import '../models/social_auth_method.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(ApiClient(dio));
});

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<AuthResponse> registerContractor(
    ContractorRegisterRequest request,
  ) async {
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

  Future<bool> checkEmailExists(String email) async {
    try {
      // By sending only the email to the specific register endpoint, 
      // the backend will respond with a 422 containing all validation errors.
      // We can inspect the errors map specifically for the 'email' field.
      await _apiClient.dio.post(
        '/api/v1/auth/register/contractor',
        data: {'email': email},
      );
      // It should never succeed due to missing required fields, but if it does, return false
      return false;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map && errors.containsKey('email')) {
            final emailErrorObj = errors['email'];
            String emailError = '';
            if (emailErrorObj is List && emailErrorObj.isNotEmpty) {
              emailError = emailErrorObj.first.toString().toLowerCase();
            } else if (emailErrorObj != null) {
              emailError = emailErrorObj.toString().toLowerCase();
            }
            
            // If the validation expressly states the email is taken
            if (emailError.contains('taken') || 
                emailError.contains('already') || 
                emailError.contains('exist')) {
              return true;
            }
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<AuthResponse> resendVerificationEmail() async {
    final response = await _apiClient.post('/api/v1/auth/email/resend');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> sendEmailVerificationOtp() async {
    final response = await _apiClient.post('/api/v1/auth/email/send-otp');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> verifyEmailOtp(String code) async {
    final response = await _apiClient.post(
      '/api/v1/auth/email/verify-otp',
      data: {'code': code},
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> verifyEmail({
    required String id,
    required String hash,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/auth/email/verify/$id/$hash',
      queryParameters: queryParameters,
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> registerOwner(
    ProductOwnerRegisterRequest request,
  ) async {
    final response = await _apiClient.post(
      '/api/v1/auth/register/owner',
      data: request.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> logout({String? token}) async {
    final response = await _apiClient.post(
      '/api/v1/auth/logout',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
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

  Future<AuthResponse> googleNativeAuth({
    required String idToken,
    required UserRole role,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/google/native',
      data: {
        'id_token': idToken,
        'role': role.socialAuthQueryValue,
      },
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return AuthResponse.fromJson(response.data);
  }

  Future<String> getSocialAuthUrl({
    required SocialAuthMethod method,
    required UserRole role,
  }) async {
    final response = await _apiClient.get(
      method.authPath,
      queryParameters: {'role': role.socialAuthQueryValue},
    );
    final payload = _requireMapResponse(response.data);
    final authUrl = payload['data']?['url']?.toString();
    if (authUrl == null || authUrl.isEmpty) {
      throw Exception(
        'Server did not return a ${method.displayName} sign-in URL.',
      );
    }
    return authUrl;
  }

  Future<AuthResponse> exchangeSocialAuthToken({
    required SocialAuthMethod method,
    String? id,
    required String token,
  }) async {
    // The backend provides the Sanctum Token directly to the frontend via the callback redirect.
    // There is no '/token' exchange endpoint. We just fetch the user profile using the token.
    try {
      final response = await _apiClient.get(
        '/api/v1/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      final data = _requireMapResponse(response.data);
      final userPayload = _extractUserPayload(data);

      return AuthResponse.fromSession(
        token: token, 
        user: userPayload,
        message: 'Signed in with ${method.displayName}',
      );
    } catch (_) {
      // Fallback to profile endpoint just like fetchCurrentUser
      final response = await _apiClient.get(
        '/api/v1/settings/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      final data = _requireMapResponse(response.data);
      final userPayload = _extractUserPayload(data);

      return AuthResponse.fromSession(
        token: token, 
        user: userPayload,
        message: 'Signed in with ${method.displayName}',
      );
    }
  }

  Future<Map<String, dynamic>> fetchCurrentUserWithToken(String token) async {
    final response = await _apiClient.get(
      '/api/v1/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return _extractUserPayload(
      _requireMapResponse(response.data),
    );
  }

  Future<Map<String, dynamic>> fetchCurrentUser({
    Map<String, dynamic>? cachedUser,
  }) async {
    try {
      final response = await _apiClient.get('/api/v1/auth/me');
      return _extractUserPayload(
        _requireMapResponse(response.data),
        fallbackUser: cachedUser,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        rethrow;
      }
    } on Exception {
      // Fall through to the profile endpoint below when `/auth/me` is not
      // available or returns an unexpected payload.
    }

    try {
      final response = await _apiClient.get('/api/v1/settings/profile');
      return _extractUserPayload(
        _requireMapResponse(response.data),
        fallbackUser: cachedUser,
      );
    } catch (_) {
      // If profile fails (like due to the 403 unverified middleware),
      // fallback to the cached user data from the login response.
      return cachedUser ?? {};
    }
  }

  Future<EmailVerificationStatus> checkEmailVerificationStatus({
    Map<String, dynamic>? cachedUser,
  }) async {
    final cachedStatus = emailVerificationStatusFromPayload({'user': cachedUser});
    if (cachedStatus.isKnown) {
      return cachedStatus;
    }

    // Bypassing the strict `/api/v1/settings/profile` check because the 
    // backend Verification controller is failing to save `email_verified_at`
    // to the database. We will rely on the dashboard health check instead, 
    // mimicking the WebApp's behavior.

    try {
      final dashboardResponse = await _apiClient.get('/api/v1/dashboard');
      if (dashboardResponse.statusCode == 200) {
        // If the dashboard call succeeds (200 OK), it implies the user is verified 
        // because the API middleware would have blocked them with a 403 otherwise.
        return EmailVerificationStatus.verified;
      }
    } on ApiException catch (e) {
      final statusFromError = emailVerificationStatusFromMessage(e.message);
      if (statusFromError.isKnown) {
        return statusFromError;
      }
      if (e.statusCode == 401) {
        rethrow;
      }
    }

    return EmailVerificationStatus.unknown;
  }

  Map<String, dynamic> _requireMapResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response format');
    }
    return data;
  }

  Map<String, dynamic> _extractUserPayload(
    Map<String, dynamic> payload, {
    Map<String, dynamic>? fallbackUser,
  }) {
    final user = _asStringMap(payload['user']);
    final data = _asStringMap(payload['data']);
    final nestedUser = data == null ? null : _asStringMap(data['user']);

    final candidates = <Map<String, dynamic>>[];
    if (user != null) {
      candidates.add(user);
    }
    if (nestedUser != null) {
      candidates.add(nestedUser);
    }
    if (data != null) {
      candidates.add(data);
    }
    candidates.add(payload);

    for (final candidate in candidates) {
      if (_looksLikeUserPayload(candidate)) {
        return {if (fallbackUser != null) ...fallbackUser, ...candidate};
      }
    }

    throw Exception('Unable to load your account right now.');
  }

  Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  bool _looksLikeUserPayload(Map<String, dynamic> payload) {
    return payload.containsKey('id') ||
        payload.containsKey('email') ||
        payload.containsKey('role') ||
        payload.containsKey('first_name') ||
        payload.containsKey('last_name');
  }
}
