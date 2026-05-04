import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/shared_prefs_provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/pusher_service.dart';
import '../../../core/ui/app_scaffold_messenger.dart';
import '../../auth/models/auth_response.dart';
import '../../auth/models/email_verification_status.dart';
import '../../messages/models/message.dart';
import '../../projects/repositories/project_repository.dart';
import '../models/notification_models.dart';
import '../providers/notification_providers.dart';
import '../repositories/notification_repository.dart';
import 'push_token_source.dart';

final deviceTokenStoreProvider = Provider<DeviceTokenStore>((ref) {
  return DeviceTokenStore(ref.read(sharedPreferencesProvider));
});

final notificationLifecycleProvider = Provider<NotificationLifecycleService>((
  ref,
) {
  return NotificationLifecycleService(ref);
});

class DeviceTokenStore {
  static const _registeredTokenKey = 'registered_device_token';
  final SharedPreferences _prefs;

  DeviceTokenStore(this._prefs);

  Future<String?> getRegisteredToken() async {
    return _prefs.getString(_registeredTokenKey);
  }

  Future<void> saveRegisteredToken(String token) async {
    await _prefs.setString(_registeredTokenKey, token);
  }

  Future<void> clearRegisteredToken() async {
    await _prefs.remove(_registeredTokenKey);
  }
}

class NotificationLifecycleService {
  static const Set<String> _projectMessageEventNames = <String>{
    'project.message.sent',
    '.project.message.sent',
  };

  final Ref _ref;
  final List<StreamSubscription<dynamic>> _messageSubscriptions = [];
  String? _activeUserId;
  String? _lastHandledRealtimeMessageId;
  Timer? _notificationPoller;
  Future<void>? _stoppingRealtimeSubscriptions;

  NotificationLifecycleService(this._ref);

  Future<void> syncForAuthState(
    AsyncValue<AuthResponse?> authState, {
    required AsyncValue<EmailVerificationStatus> verificationState,
  }) async {
    if (authState.isLoading) return;

    final response = authState.asData?.value;
    final isAuthenticated =
        response != null &&
        response.status &&
        response.data != null &&
        response.data!.token.isNotEmpty;

    if (!isAuthenticated) {
      if (_activeUserId != null) {
        await _stopRealtimeMessageSubscriptions();
      }
      _activeUserId = null;
      _lastHandledRealtimeMessageId = null;
      _stopNotificationPolling();
      return;
    }

    final user = response.data!.user;
    final userId = user['id']?.toString();
    if (userId == null || userId.isEmpty) return;

    final verificationStatus = verificationState.asData?.value;
    if (verificationState.isLoading ||
        verificationStatus == null ||
        verificationStatus == EmailVerificationStatus.unknown) {
      return;
    }

    if (verificationStatus == EmailVerificationStatus.unverified) {
      if (_activeUserId != null) {
        await _stopRealtimeMessageSubscriptions();
        _activeUserId = null;
      }
      _stopNotificationPolling();
      return;
    }

    if (_ref.read(nativePushSupportedProvider)) {
      unawaited(registerCurrentDeviceToken());
    }

    if (_activeUserId == userId) return;

    await _stopRealtimeMessageSubscriptions();
    _activeUserId = userId;

    await _startRealtimeMessageSubscriptions(
      role: response.role,
      currentUserId: userId,
    );
    _startNotificationPolling();
  }

  Future<bool> registerCurrentDeviceToken() async {
    final tokenSource = _ref.read(pushTokenSourceProvider);
    if (!tokenSource.isConfigured) {
      debugPrint(
        '[Notifications] Native device push is not configured on this build.',
      );
      return false;
    }

    final deviceToken = await tokenSource.getToken();
    if (deviceToken == null || deviceToken.isEmpty) {
      debugPrint(
        '[Notifications] No device token is currently available to register.',
      );
      return false;
    }

    final store = _ref.read(deviceTokenStoreProvider);
    final lastRegisteredToken = await store.getRegisteredToken();
    if (lastRegisteredToken == deviceToken) {
      return true;
    }

    final repository = _ref.read(notificationRepositoryProvider);
    await repository.registerDeviceToken(
      RegisterDeviceTokenPayload(token: deviceToken, platform: _platformName),
    );
    await store.saveRegisteredToken(deviceToken);
    return true;
  }

  Future<void> unregisterCurrentDeviceToken({String? authToken}) async {
    final store = _ref.read(deviceTokenStoreProvider);
    final registeredToken = await store.getRegisteredToken();
    if (registeredToken == null || registeredToken.isEmpty) {
      return;
    }

    final repository = _ref.read(notificationRepositoryProvider);
    try {
      await repository.unregisterDeviceToken(
        registeredToken,
        authToken: authToken,
      );
    } on ApiException catch (e) {
      if (e.statusCode != 401) {
        rethrow;
      }
      debugPrint(
        '[Notifications] Device token cleanup skipped because the session is already unauthenticated.',
      );
    } finally {
      await store.clearRegisteredToken();
    }
  }

  Future<void> handleLoggedOut() async {
    await _stopRealtimeMessageSubscriptions();
    _activeUserId = null;
    _lastHandledRealtimeMessageId = null;
    _stopNotificationPolling();
    _ref.read(pusherServiceProvider).disconnect();
  }

  Future<void> _startRealtimeMessageSubscriptions({
    required UserRole role,
    required String currentUserId,
  }) async {
    final repository = _ref.read(projectRepositoryProvider);
    final pusherService = _ref.read(pusherServiceProvider);
    List<String> projectIds;

    try {
      projectIds = await _fetchAllProjectIds(repository, role);
    } catch (e) {
      debugPrint(
        '[Notifications] Skipping realtime subscriptions because project access is unavailable: $e',
      );
      return;
    }

    for (final projectId in projectIds) {
      try {
        final channel = await pusherService.subscribeToProject(projectId);
        for (final eventName in _projectMessageEventNames) {
          final subscription = channel.bind(eventName).listen((event) {
            _handleProjectMessageEvent(
              event: event,
              projectId: projectId,
              currentUserId: currentUserId,
            );
          });
          _messageSubscriptions.add(subscription);
        }
      } catch (e) {
        debugPrint(
          '[Notifications] Failed to subscribe to project $projectId: $e',
        );
      }
    }
  }

  Future<List<String>> _fetchAllProjectIds(
    ProjectRepository repository,
    UserRole role,
  ) async {
    final ids = <String>{};
    var page = 1;
    var lastPage = 1;

    do {
      final response = role == UserRole.projectOwner
          ? await repository.fetchProjects(page: page)
          : await repository.fetchAssignedProjects(page: page);
      for (final project in response.data) {
        if (project.id.isNotEmpty) {
          ids.add(project.id);
        }
      }
      lastPage = response.meta?.lastPage ?? 1;
      page++;
    } while (page <= lastPage);

    return ids.toList(growable: false);
  }

  void _handleProjectMessageEvent({
    required dynamic event,
    required String projectId,
    required String currentUserId,
  }) {
    final payload = event?.data;
    if (payload == null || payload is! Map || payload['message'] == null) {
      return;
    }

    try {
      final message = Message.fromJson(
        Map<String, dynamic>.from(payload['message'] as Map),
      );

      if (message.id.isNotEmpty &&
          _lastHandledRealtimeMessageId == message.id) {
        return;
      }
      _lastHandledRealtimeMessageId = message.id;

      if (message.sender?.id == currentUserId) {
        return;
      }

      // Invalidate notifications to trigger refetch from backend API
      _ref.invalidate(notificationsProvider(false));
      _ref.invalidate(notificationsProvider(true));

      final senderName = [
        message.sender?.firstName ?? '',
        message.sender?.lastName ?? '',
      ].where((part) => part.isNotEmpty).join(' ');

      debugPrint(
        '[Notifications] Message from $senderName: ${message.body} (Project: $projectId)',
      );

      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            senderName.isNotEmpty
                ? '$senderName sent a message: ${message.body}'
                : 'New message: ${message.body}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        '[Notifications] Failed to parse realtime message for $projectId: $e',
      );
    }
  }

  Future<void> _stopRealtimeMessageSubscriptions() {
    final inFlightStop = _stoppingRealtimeSubscriptions;
    if (inFlightStop != null) {
      return inFlightStop;
    }

    final stopFuture = _doStopRealtimeMessageSubscriptions();
    _stoppingRealtimeSubscriptions = stopFuture.whenComplete(() {
      if (identical(_stoppingRealtimeSubscriptions, stopFuture)) {
        _stoppingRealtimeSubscriptions = null;
      }
    });

    return _stoppingRealtimeSubscriptions!;
  }

  Future<void> _doStopRealtimeMessageSubscriptions() async {
    if (_messageSubscriptions.isEmpty) {
      return;
    }

    final subscriptions = List<StreamSubscription<dynamic>>.from(
      _messageSubscriptions,
    );
    _messageSubscriptions.clear();

    for (final subscription in subscriptions) {
      try {
        await subscription.cancel();
      } catch (e) {
        debugPrint(
          '[Notifications] Ignoring realtime subscription cleanup error: $e',
        );
      }
    }
  }

  void _startNotificationPolling() {
    _notificationPoller?.cancel();
    // Lightweight foreground poll to keep notifications fresh, mirroring web behaviour.
    _notificationPoller = Timer.periodic(const Duration(seconds: 30), (_) {
      _ref.invalidate(notificationsProvider(false));
      _ref.invalidate(notificationsProvider(true));
    });
  }

  void _stopNotificationPolling() {
    _notificationPoller?.cancel();
    _notificationPoller = null;
  }

  String get _platformName {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
