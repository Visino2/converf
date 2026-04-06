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
    try {
      final response = await _apiClient.get('/api/v1/dashboard');
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }
      return DashboardResponse.fromJson(response.data);
    } on ApiException catch (e) {
      if (e.statusCode == 403 && (e.message.contains('not verified') || e.message.contains('verify your email'))) {
        // Return an empty stats response instead of crashing for the unverified bypass.
        return DashboardResponse(
          status: true,
          message: 'Offline (Unverified)',
          data: DashboardData(
            activeProjects: 0,
            avgQualityScore: 0.0,
            ballInCourts: 0,
            portfolioValue: 0,
            activeTasks: 0,
            pendingInvoices: 0,
            upcomingMilestones: 0,
            totalEarned: '₦0',
          ),
        );
      }
      rethrow;
    }
  }
}
