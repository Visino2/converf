import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/dio_provider.dart';
import '../models/phase_models.dart';

class PhaseRepository {
  final ApiClient _apiClient;

  PhaseRepository(this._apiClient);

  Future<PhasesResponse> fetchPhases(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/phases');
    return PhasesResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

final phaseRepositoryProvider = Provider<PhaseRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PhaseRepository(ApiClient(dio));
});
