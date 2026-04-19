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
  
  final channel = await pusherService.subscribeToProject(projectId);
  final subscriptions = <StreamSubscription<dynamic>>[];

  for (final eventName in eventNames) {
    final subscription = channel.bind(eventName).listen((event) {
      final data = event.data;
      if (data != null && data is Map) {
        try {
          if (data['message'] != null) {
            final messageMap = Map<String, dynamic>.from(data['message']);
            final newMessage = Message.fromJson(messageMap);
            if (!currentMessages.any((m) => m.id == newMessage.id)) {
              currentMessages = [...currentMessages, newMessage];
              ref.invalidate(notificationsProvider(false));
              ref.invalidate(notificationsProvider(true));
              ref.invalidate(unreadNotificationsCountProvider);
              if (!controller.isClosed) {
                controller.add(currentMessages);
              }
            }
          }
        } catch (e) {
          debugPrint("[projectMessagesProvider] Error: $e");
        }
      }
    });
    subscriptions.add(subscription);
  }

  ref.onDispose(() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    pusherService.unsubscribe('private-project.$projectId');
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
