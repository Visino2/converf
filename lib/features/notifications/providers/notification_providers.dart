import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_models.dart';
import '../repositories/notification_repository.dart';

final notificationsProvider =
    FutureProvider.autoDispose.family<List<AppNotification>, bool>((ref, unreadOnly) async {
      final repository = ref.read(notificationRepositoryProvider);
      return repository.fetchNotifications(unreadOnly: unreadOnly);
    });

final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final unreadNotifications = await ref.watch(
    notificationsProvider(true).future,
  );
  return unreadNotifications.length;
});

final unreadMessageNotificationsCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final unreadNotifications = await ref.watch(
    notificationsProvider(true).future,
  );
  return unreadNotifications
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
    ref.invalidate(unreadNotificationsCountProvider);
    ref.invalidate(unreadMessageNotificationsCountProvider);
  }
}

final notificationActionProvider =
    AsyncNotifierProvider<NotificationActionNotifier, void>(
      NotificationActionNotifier.new,
    );
