class DashboardData {
  final int activeProjects;
  final double avgQualityScore;
  final int ballInCourts;
  final num portfolioValue;

  DashboardData({
    required this.activeProjects,
    required this.avgQualityScore,
    required this.ballInCourts,
    required this.portfolioValue,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      activeProjects: json['active_projects'] as int? ?? 0,
      avgQualityScore: (json['avg_quality_score'] as num?)?.toDouble() ?? 0.0,
      ballInCourts: json['ball_in_courts'] as int? ?? 0,
      portfolioValue: json['portfolio_value'] as num? ?? 0,
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
