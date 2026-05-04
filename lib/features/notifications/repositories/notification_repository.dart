import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/notification_models.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(ApiClient(dio));
});

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<AppNotification>> fetchNotifications({
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/notifications',
        queryParameters: {if (unreadOnly) 'unread_only': true},
      );

      debugPrint(
        '[NotifRepo] Raw response data type: ${response.data.runtimeType}',
      );
      debugPrint('[NotifRepo] Raw response: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final parsed = NotificationsResponse.fromJson(
          response.data as Map<String, dynamic>,
        ).data;
        debugPrint(
          '[NotifRepo] Parsed ${parsed.length} notifications from Map response',
        );
        for (final notif in parsed) {
          debugPrint(
            '[NotifRepo]   - Type: ${notif.type}, Title: ${notif.title}, Body: ${notif.body}',
          );
        }
        return parsed;
      }

      if (response.data is List<dynamic>) {
        final parsed = (response.data as List<dynamic>)
            .whereType<Map>()
            .map(
              (item) =>
                  AppNotification.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
        debugPrint(
          '[NotifRepo] Parsed ${parsed.length} notifications from List response',
        );
        for (final notif in parsed) {
          debugPrint(
            '[NotifRepo]   - Type: ${notif.type}, Title: ${notif.title}, Body: ${notif.body}',
          );
        }
        return parsed;
      }

      throw Exception('Invalid response format from server');
    } on ApiException catch (e) {
      if (e.statusCode == 403 &&
          (e.message.contains('not verified') ||
              e.message.contains('verify your email'))) {
        // Return empty notifications list for the unverified bypass.
        debugPrint('[NotifRepo] Returning empty list for unverified email');
        return [];
      }
      debugPrint(
        '[NotifRepo] ApiException: statusCode=${e.statusCode}, message=${e.message}',
      );
      rethrow;
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _apiClient.patch('/api/v1/notifications/$notificationId/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _apiClient.post('/api/v1/notifications/read-all');
  }

  Future<void> registerDeviceToken(RegisterDeviceTokenPayload payload) async {
    await _apiClient.post('/api/v1/device-tokens', data: payload.toJson());
  }

  Future<void> unregisterDeviceToken(String token, {String? authToken}) async {
    await _apiClient.delete(
      '/api/v1/device-tokens',
      data: {'token': token},
      options: authToken != null && authToken.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $authToken'})
          : null,
    );
  }
}
