import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/pusher_service.dart';
import '../../notifications/providers/notification_providers.dart';
import '../models/message.dart';
import '../repositories/message_repository.dart';

final projectMessagesProvider = StreamProvider.autoDispose.family<List<Message>, String>((ref, projectId) async* {
  final repository = ref.read(messageRepositoryProvider);
  final pusherService = ref.watch(pusherServiceProvider);
  const eventNames = <String>{
    'project.message.sent',
    '.project.message.sent',
  };

  // Initial fetch
  try {
    await repository.markMessagesRead(projectId);
  } catch (_) {}

  List<Message> currentMessages = await repository.fetchProjectMessages(projectId);
  yield currentMessages;

  final controller = StreamController<List<Message>>();

  void updateMessages(List<Message> updated) {
    currentMessages = updated;
    ref.invalidate(notificationsProvider(false));
    ref.invalidate(notificationsProvider(true));
    ref.invalidate(unreadNotificationsCountProvider);
    if (!controller.isClosed) controller.add(currentMessages);
  }

  // Pusher real-time subscription
  final subscriptions = <StreamSubscription<dynamic>>[];
  bool pusherConnected = false;
  try {
    final channel = await pusherService.subscribeToProject(projectId);
    pusherConnected = true;
    for (final eventName in eventNames) {
      final subscription = channel.bind(eventName).listen((event) {
        final data = event.data;
        if (data != null && data is Map) {
          try {
            if (data['message'] != null) {
              final messageMap = Map<String, dynamic>.from(data['message'] as Map);
              final newMessage = Message.fromJson(messageMap);
              if (!currentMessages.any((m) => m.id == newMessage.id)) {
                updateMessages([...currentMessages, newMessage]);
              }
            }
          } catch (e) {
            debugPrint("[projectMessagesProvider] Error: $e");
          }
        }
      });
      subscriptions.add(subscription);
    }
  } catch (e) {
    debugPrint("[projectMessagesProvider] Pusher unavailable, using polling: $e");
    pusherConnected = false;
  }

  // Polling fallback — runs every 8 seconds when Pusher is unavailable,
  // or every 15 seconds as a safety net when Pusher is connected.
  final pollInterval = pusherConnected
      ? const Duration(seconds: 15)
      : const Duration(seconds: 8);
  final pollTimer = Timer.periodic(pollInterval, (_) async {
    try {
      final latest = await repository.fetchProjectMessages(projectId);
      final existingIds = currentMessages.map((m) => m.id).toSet();
      final hasNew = latest.any((m) => !existingIds.contains(m.id));
      if (hasNew) {
        updateMessages(latest);
      }
    } catch (_) {}
  });

  ref.onDispose(() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    pusherService.unsubscribe('private-project.$projectId');
    pollTimer.cancel();
    controller.close();
  });

  yield* controller.stream;
});


class SendMessageNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> send(String projectId, String body) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(messageRepositoryProvider);
      await repository.sendProjectMessage(projectId, body);
      state = const AsyncData(null);
      
      ref.invalidate(projectMessagesProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final sendMessageProvider = AsyncNotifierProvider.autoDispose<SendMessageNotifier, void>(SendMessageNotifier.new);


class DeleteMessageNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> delete(String projectId, String messageId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(messageRepositoryProvider);
      await repository.deleteMessage(projectId, messageId);
      state = const AsyncData(null);
      ref.invalidate(projectMessagesProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final deleteMessageProvider = AsyncNotifierProvider.autoDispose<DeleteMessageNotifier, void>(DeleteMessageNotifier.new);
