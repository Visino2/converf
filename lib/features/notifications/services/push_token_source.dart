import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PushTokenSource {
  const PushTokenSource();

  bool get isConfigured;
  Future<String?> getToken();
}

final pushTokenSourceProvider = Provider<PushTokenSource>((ref) {
  return FirebasePushTokenSource(FirebaseMessaging.instance);
});

final nativePushSupportedProvider = Provider<bool>((ref) {
  return ref.watch(pushTokenSourceProvider).isConfigured;
});

class NoopPushTokenSource extends PushTokenSource {
  const NoopPushTokenSource();

  @override
  bool get isConfigured => false;

  @override
  Future<String?> getToken() async => null;
}

class FirebasePushTokenSource extends PushTokenSource {
  const FirebasePushTokenSource(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  bool get isConfigured {
    if (kIsWeb || Firebase.apps.isEmpty) {
      return false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  @override
  Future<String?> getToken() async {
    if (!isConfigured) {
      return null;
    }

    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[Notifications] Failed to fetch FCM token: $e');
      return null;
    }
  }
}
