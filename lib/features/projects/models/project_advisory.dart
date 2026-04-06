import 'package:flutter/material.dart';

enum AdvisoryType {
  schedule,
  quality,
  budget,
  general;

  static AdvisoryType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'schedule': return AdvisoryType.schedule;
      case 'quality': return AdvisoryType.quality;
      case 'budget': return AdvisoryType.budget;
      default: return AdvisoryType.general;
    }
  }

  IconData get icon {
    switch (this) {
      case AdvisoryType.schedule: return Icons.schedule_outlined;
      case AdvisoryType.quality: return Icons.verified_outlined;
      case AdvisoryType.budget: return Icons.account_balance_wallet_outlined;
      default: return Icons.info_outline;
    }
  }

  Color get color {
    switch (this) {
      case AdvisoryType.schedule: return const Color(0xFFB54708);
      case AdvisoryType.quality: return const Color(0xFF027A48);
      case AdvisoryType.budget: return const Color(0xFF1D4ED8);
      default: return const Color(0xFF667085);
    }
  }

  Color get bgColor {
    switch (this) {
      case AdvisoryType.schedule: return const Color(0xFFFFFAEB);
      case AdvisoryType.quality: return const Color(0xFFECFDF3);
      case AdvisoryType.budget: return const Color(0xFFF0F9FF);
      default: return const Color(0xFFF9FAFB);
    }
  }
}

class ProjectAdvisoryItem {
  final String title;
  final String body;
  final AdvisoryType type;
  final String? recommendation;

  ProjectAdvisoryItem({
    required this.title,
    required this.body,
    required this.type,
    this.recommendation,
  });

  factory ProjectAdvisoryItem.fromJson(Map<String, dynamic> json) {
    return ProjectAdvisoryItem(
      title: json['title'] as String? ?? 'Advisory',
      body: json['body'] as String? ?? (json['message'] as String?) ?? '',
      type: AdvisoryType.fromString(json['type'] as String?),
      recommendation: json['recommendation'] as String?,
    );
  }
}

class ProjectAdvisoryResponse {
  final int healthScore;
  final String healthMessage;
  final List<ProjectAdvisoryItem> advisories;

  ProjectAdvisoryResponse({
    required this.healthScore,
    required this.healthMessage,
    required this.advisories,
  });

  factory ProjectAdvisoryResponse.fromJson(Map<String, dynamic> json) {
    // Handle wrap in 'data' field
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return ProjectAdvisoryResponse(
      healthScore: (data['health_score'] as num?)?.toInt() ?? 0,
      healthMessage: data['health_message'] as String? ?? 'Converf AI is analyzing your project.',
      advisories: (data['advisories'] as List<dynamic>?)
          ?.map((e) => ProjectAdvisoryItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
