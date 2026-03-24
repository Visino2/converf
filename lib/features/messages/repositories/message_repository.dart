import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_provider.dart';
import '../../../core/api/api_client.dart';
import '../models/message.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MessageRepository(ApiClient(dio));
});

class MessageRepository {
  final ApiClient _apiClient;

  MessageRepository(this._apiClient);

  Future<List<Message>> fetchProjectMessages(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/messages');
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    final result = MessageResponse.fromJson(response.data);
    return result.data ?? [];
  }

  Future<Message> sendProjectMessage(String projectId, String body) async {
    final response = await _apiClient.post(
      '/api/v1/projects/$projectId/messages',
      data: {'body': body},
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    final result = SingleMessageResponse.fromJson(response.data);
    if (result.data == null) {
      throw Exception("Message data missing in response");
    }
    return result.data!;
  }

  Future<void> markMessagesRead(String projectId) async {
    await _apiClient.patch('/api/v1/projects/$projectId/messages/read');
  }

  Future<void> deleteMessage(String projectId, String messageId) async {
    await _apiClient.delete('/api/v1/projects/$projectId/messages/$messageId');
  }
}
