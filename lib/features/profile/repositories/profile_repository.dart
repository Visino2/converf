import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(ApiClient(dio));
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<UserProfile> fetchProfile() async {
    final response = await _apiClient.get('/api/v1/settings/profile');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    final data = response.data as Map<String, dynamic>;
    return UserProfile.fromJson(data['data'] ?? data);
  }

  Future<UserProfile> updateProfile(UpdateProfilePayload payload) async {
    final response = await _apiClient.patch(
      '/api/v1/settings/profile',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    final data = response.data as Map<String, dynamic>;
    return UserProfile.fromJson(data['data'] ?? data);
  }

  Future<void> changePassword(ChangePasswordPayload payload) async {
    await _apiClient.patch(
      '/api/v1/settings/security/password',
      data: payload.toJson(),
    );
  }

  Future<UserProfile> updateProfilePicture(String filePath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final response = await _apiClient.post(
      '/api/v1/settings/profile/photo',
      data: formData,
    );
    
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    final data = response.data as Map<String, dynamic>;
    return UserProfile.fromJson(data['data'] ?? data);
  }

  Future<NotificationSettings> fetchNotificationSettings() async {
    final response = await _apiClient.get('/api/v1/settings/notifications');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    final data = response.data as Map<String, dynamic>;
    // According to web API, response is { status, message, data: { settings: ... } }
    final settingsData = (data['data'] as Map<String, dynamic>)['settings'] ?? data['data'];
    return NotificationSettings.fromJson(settingsData as Map<String, dynamic>);
  }

  Future<NotificationSettings> updateNotificationSettings(Map<String, dynamic> settings) async {
    final response = await _apiClient.patch(
      '/api/v1/settings/notifications',
      data: {'settings': settings},
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    final data = response.data as Map<String, dynamic>;
    final settingsData = (data['data'] as Map<String, dynamic>)['settings'] ?? data['data'];
    return NotificationSettings.fromJson(settingsData as Map<String, dynamic>);
  }
}
