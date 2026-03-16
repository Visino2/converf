import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_provider.dart';
import '../../../core/api/api_client.dart';
import '../models/dashboard_stats.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepository(ApiClient(dio));
});

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardResponse> fetchDashboardStats() async {
    final response = await _apiClient.get('/api/v1/dashboard');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return DashboardResponse.fromJson(response.data);
  }
}
