class DashboardData {
  final int activeProjects;
  final double avgQualityScore;
  final int ballInCourts;
  final num portfolioValue;
  final int activeTasks;
  final int pendingInvoices;
  final int upcomingMilestones;
  final String? totalSpent;
  final String? totalEarned;

  DashboardData({
    required this.activeProjects,
    required this.avgQualityScore,
    required this.ballInCourts,
    required this.portfolioValue,
    required this.activeTasks,
    required this.pendingInvoices,
    required this.upcomingMilestones,
    this.totalSpent,
    this.totalEarned,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      activeProjects: json['active_projects'] as int? ?? 0,
      avgQualityScore: (json['avg_quality_score'] as num?)?.toDouble() ?? 0.0,
      ballInCourts: json['ball_in_courts'] as int? ?? 0,
      portfolioValue: json['portfolio_value'] as num? ?? 0,
      activeTasks: json['active_tasks'] as int? ?? 0,
      pendingInvoices: json['pending_invoices'] as int? ?? 0,
      upcomingMilestones: json['upcoming_milestones'] as int? ?? 0,
      totalSpent: json['total_spent']?.toString(),
      totalEarned: json['total_earned']?.toString(),
    );
  }
}

class DashboardResponse {
  final bool status;
  final String message;
  final DashboardData? data;

  DashboardResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? DashboardData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}
