import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/app_scaffold_messenger.dart';
import '../../auth/models/auth_response.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/notification_models.dart';
import '../providers/notification_providers.dart';
import 'notification_lifecycle_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((
  ref,
) {
  return FirebaseMessagingService(ref);
});

class FirebaseMessagingService {
  FirebaseMessagingService(this._ref);

  final Ref _ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialized = false;

  Future<void> initialize(GoRouter router) async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (Firebase.apps.isEmpty) {
      debugPrint('[FirebaseMessaging] Firebase is not initialized.');
      return;
    }

    try {
      await _messaging.setAutoInitEnabled(true);
    } catch (e) {
      debugPrint('[FirebaseMessaging] Failed to enable auto-init: $e');
    }

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint('[FirebaseMessaging] Permission request failed: $e');
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        debugPrint(
          '[FirebaseMessaging] Failed to configure iOS foreground options: $e',
        );
      }
    }

    FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
      onError: (Object error) {
        debugPrint('[FirebaseMessaging] Foreground listener error: $error');
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        unawaited(_handleOpenedMessage(message, router));
      },
      onError: (Object error) {
        debugPrint('[FirebaseMessaging] Tap listener error: $error');
      },
    );

    _messaging.onTokenRefresh.listen(
      (_) {
        unawaited(
          _ref.read(notificationLifecycleProvider).registerCurrentDeviceToken(),
        );
      },
      onError: (Object error) {
        debugPrint('[FirebaseMessaging] Token refresh listener error: $error');
      },
    );

    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        await _handleOpenedMessage(initialMessage, router);
      }
    } catch (e) {
      debugPrint('[FirebaseMessaging] Failed to read initial message: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _invalidateNotificationCaches();

    final appNotification = _toAppNotification(message);
    if (appNotification.isMessageNotification) {
      return;
    }

    final title = appNotification.title.trim();
    final body = appNotification.body.trim();

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    appScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          body.isEmpty ? title : '$title\n$body',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _handleOpenedMessage(
    RemoteMessage message,
    GoRouter router,
  ) async {
    _invalidateNotificationCaches();

    final authResponse = _ref.read(authProvider).asData?.value;
    if (authResponse == null || !authResponse.isAuthenticated) {
      return;
    }

    final appNotification = _toAppNotification(message);
    final location = _notificationLocationFor(
      notification: appNotification,
      role: authResponse.role,
    );
    if (location == null || location.isEmpty) {
      return;
    }

    router.go(location);
  }

  AppNotification _toAppNotification(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);

    return AppNotification.fromJson({
      'id': message.messageId ?? data['id'] ?? '',
      'type':
          data['type'] ??
          data['notification_type'] ??
          data['event'] ??
          data['category'] ??
          'notification',
      'title': message.notification?.title ?? data['title'] ?? '',
      'body':
          message.notification?.body ??
          data['body'] ??
          data['message'] ??
          data['text'] ??
          '',
      'data': data,
    });
  }

  String? _notificationLocationFor({
    required AppNotification notification,
    required UserRole role,
  }) {
    final projectId = notification.projectId;
    if (notification.isMessageNotification) {
      return '/messages';
    }

    if (projectId != null && projectId.isNotEmpty) {
      return role == UserRole.contractor
          ? '/contractor-projects/$projectId'
          : '/projects/$projectId';
    }

    switch (role) {
      case UserRole.contractor:
        return '/contractor-notifications';
      case UserRole.projectOwner:
        return '/notifications';
      case UserRole.unknown:
        return null;
    }
  }

  void _invalidateNotificationCaches() {
    _ref.invalidate(notificationsProvider(false));
    _ref.invalidate(notificationsProvider(true));
  }
}
