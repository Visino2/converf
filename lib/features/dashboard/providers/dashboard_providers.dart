import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/dashboard_repository.dart';
import '../models/dashboard_stats.dart';

final dashboardStatsProvider = FutureProvider<DashboardResponse>((ref) async {
  final repository = ref.read(dashboardRepositoryProvider);
  return repository.fetchDashboardStats();
});
