import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/ai_credits_models.dart';

final aiCreditsRepositoryProvider = Provider<AiCreditsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AiCreditsRepository(ApiClient(dio));
});

class AiCreditsRepository {
  AiCreditsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AiCreditsBalance> fetchAiCredits() async {
    final response = await _apiClient.get('/api/v1/ai-credits');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    return AiCreditsBalance.fromJson(response.data as Map<String, dynamic>);
  }
}
