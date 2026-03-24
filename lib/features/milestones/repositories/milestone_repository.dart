import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/dio_provider.dart';
import '../models/milestone_models.dart';

class MilestoneRepository {
  final ApiClient _apiClient;

  MilestoneRepository(this._apiClient);

  Future<MilestonesResponse> fetchMilestones(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/milestones');
    return MilestonesResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MilestoneRepository(ApiClient(dio));
});
