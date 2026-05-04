import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_models.dart';
import '../repositories/notification_repository.dart';

final notificationsProvider =
    FutureProvider.autoDispose.family<List<AppNotification>, bool>((ref, unreadOnly) async {
      final repository = ref.read(notificationRepositoryProvider);
      return repository.fetchNotifications(unreadOnly: unreadOnly);
    });

// Synchronous providers — derive from the shared notificationsProvider(true)
// instance so no duplicate API calls are made when counts are needed.
final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(notificationsProvider(true)).asData?.value.length ?? 0;
});

final unreadMessageNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifications =
      ref.watch(notificationsProvider(true)).asData?.value ?? [];
  return notifications
      .where((notification) => notification.isMessageNotification)
      .length;
});

class NotificationActionNotifier extends AsyncNotifier<void> {
  late NotificationRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(notificationRepositoryProvider);
  }

  Future<void> markRead(String notificationId) async {
    state = const AsyncLoading();
    try {
      await _repository.markNotificationRead(notificationId);
      _invalidateNotificationState();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    state = const AsyncLoading();
    try {
      await _repository.markAllNotificationsRead();
      _invalidateNotificationState();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> markMessageNotificationsRead({String? projectId}) async {
    state = const AsyncLoading();
    try {
      final unreadNotifications = await _repository.fetchNotifications(
        unreadOnly: true,
      );
      final notificationsToMark = unreadNotifications.where((notification) {
        if (!notification.isMessageNotification) {
          return false;
        }

        if (projectId == null || projectId.isEmpty) {
          return true;
        }

        return notification.projectId == projectId;
      });

      for (final notification in notificationsToMark) {
        await _repository.markNotificationRead(notification.id);
      }

      _invalidateNotificationState();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  void _invalidateNotificationState() {
    ref.invalidate(notificationsProvider(false));
    ref.invalidate(notificationsProvider(true));
    // Count providers auto-derive from notificationsProvider(true) — no explicit invalidation needed
  }
}

final notificationActionProvider =
    AsyncNotifierProvider<NotificationActionNotifier, void>(
      NotificationActionNotifier.new,
    );
