import 'package:flutter/foundation.dart';
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
    debugPrint('[DashboardRepo] Calling /api/v1/dashboard...');
    try {
      final response = await _apiClient.get('/api/v1/dashboard');
      debugPrint('[DashboardRepo] Response received: ${response.statusCode}');
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }
      final result = DashboardResponse.fromJson(response.data);
      debugPrint('[DashboardRepo] Parsing successful. Active projects: ${result.data?.activeProjects}');
      return result;
    } on ApiException catch (e) {
      debugPrint('[DashboardRepo] ApiException: ${e.statusCode} - ${e.message}');
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
