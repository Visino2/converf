import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ProjectStatus {
  draft,
  pendingTender,
  active,
  completed,
  onHold,
  cancelled,
  atRisk,
  delayed,
  onTrack;

  String toJson() {
    switch (this) {
      case ProjectStatus.draft:
        return 'draft';
      case ProjectStatus.pendingTender:
        return 'pending_tender';
      case ProjectStatus.active:
        return 'active';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.onHold:
        return 'on_hold';
      case ProjectStatus.cancelled:
        return 'cancelled';
      case ProjectStatus.atRisk:
        return 'at_risk';
      case ProjectStatus.delayed:
        return 'delayed';
      case ProjectStatus.onTrack:
        return 'on_track';
    }
  }

  static ProjectStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return ProjectStatus.draft;
      case 'pending_tender':
        return ProjectStatus.pendingTender;
      case 'active':
        return ProjectStatus.active;
      case 'completed':
        return ProjectStatus.completed;
      case 'on_hold':
        return ProjectStatus.onHold;
      case 'cancelled':
        return ProjectStatus.cancelled;
      case 'at_risk':
      case 'atrisk':
        return ProjectStatus.atRisk;
      case 'delayed':
        return ProjectStatus.delayed;
      case 'on_track':
      case 'ontrack':
        return ProjectStatus.onTrack;
      default:
        // Attempt to match by name if snake_case fails
        return ProjectStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == status.toLowerCase(),
          orElse: () => ProjectStatus.draft,
        );
    }
  }

  String get label {
    switch (this) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.pendingTender:
        return 'Pending Tender';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.cancelled:
        return 'Cancelled';
      case ProjectStatus.atRisk:
        return 'At Risk';
      case ProjectStatus.delayed:
        return 'Delayed';
      case ProjectStatus.onTrack:
        return 'On Track';
    }
  }

  dynamic get color {
    // Note: To avoid direct dependency on flutter/material.dart in the model file,
    // we could return hex strings or use an extension in a UI-aware file.
    // However, the current UI expects .color to return a Color object.
    // Since this project already has some mixing, I'll provide standard hex codes or Map.
    switch (this) {
      case ProjectStatus.completed:
        return const Color(0xFF10B981); // Success
      case ProjectStatus.atRisk:
        return const Color(0xFFF59E0B); // Warning
      case ProjectStatus.delayed:
        return const Color(0xFFEF4444); // Error
      case ProjectStatus.onTrack:
        return const Color(0xFF3B82F6); // Info
      case ProjectStatus.onHold:
        return const Color(0xFF6B7280); // Secondary
      default:
        return const Color(0xFF374151); // Gray
    }
  }
}

class ProjectParty {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;

  ProjectParty({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
  });

  factory ProjectParty.fromJson(Map<String, dynamic> json) {
    return ProjectParty(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final String constructionType;
  final ProjectStatus status;
  final int currentStep;
  final bool isBookmarked;
  final String budget;
  final String currency;
  final String startDate;
  final String endDate;
  final String location;
  final String city;
  final String state;
  final String country;
  final String urgencyLevel;
  final String assignmentMethod;
  final String? biddingDeadline;
  final int? bidsCount;
  final String? contractorId;
  final ProjectParty? contractor;
  final ProjectParty? owner;
  final num? matchRate;
  final String? constructionSubType;
  final List<String> specialisations;
  final String createdAt;
  final String? updatedAt;

  String get formattedLocation {
    final parts = [city, state, country].where((s) => s.isNotEmpty);
    return parts.isEmpty ? location : parts.join(', ');
  }

  String get formattedDates {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final formatter = DateFormat('MMM d, yyyy');
      return '${formatter.format(start)} - ${formatter.format(end)}';
    } catch (e) {
      return '$startDate - $endDate';
    }
  }

  String get formattedBudget {
    try {
      final amount = num.parse(budget);
      final formatter = NumberFormat.currency(
        symbol: currency == 'NGN' ? '₦' : (currency == 'USD' ? '\$' : currency),
        decimalDigits: 0,
      );
      return formatter.format(amount);
    } catch (e) {
      return '$currency $budget';
    }
  }

  String? get formattedBiddingDeadline {
    if (biddingDeadline == null) return null;
    try {
      final deadline = DateTime.parse(biddingDeadline!);
      return DateFormat('MMM d, yyyy').format(deadline);
    } catch (e) {
      return biddingDeadline;
    }
  }

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.constructionType,
    required this.status,
    required this.currentStep,
    required this.isBookmarked,
    required this.budget,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
    required this.urgencyLevel,
    required this.assignmentMethod,
    this.biddingDeadline,
    this.bidsCount,
    this.contractorId,
    this.contractor,
    this.owner,
    this.matchRate,
    this.constructionSubType,
    required this.specialisations,
    required this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      constructionType: json['construction_type'] as String? ?? '',
      status: ProjectStatus.fromString(json['status'] as String? ?? ''),
      currentStep: json['current_step'] as int? ?? 1,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      budget: json['budget']?.toString() ?? '0',
      currency: json['currency'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      location: json['location'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      urgencyLevel: json['urgency_level'] as String? ?? 'medium',
      assignmentMethod: json['assignment_method'] as String? ?? '',
      biddingDeadline: json['bidding_deadline'] as String?,
      bidsCount: json['bids_count'] as int?,
      contractorId: json['contractor_id']?.toString(),
      contractor: json['contractor'] != null
          ? ProjectParty.fromJson(json['contractor'] as Map<String, dynamic>)
          : null,
      owner: json['owner'] != null
          ? ProjectParty.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      matchRate: json['match_rate'] as num?,
      constructionSubType: json['construction_sub_type'] as String?,
      specialisations: (json['specialisations'] as List<dynamic>?)
              ?.map((e) => (e as Map<String, dynamic>)['specialisation'] as String)
              .toList() ??
          [],
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class ProjectFinancials {
  final num totalContractValue;
  final num totalEarned;
  final num totalPaid;
  final String currency;

  ProjectFinancials({
    required this.totalContractValue,
    required this.totalEarned,
    required this.totalPaid,
    required this.currency,
  });

  factory ProjectFinancials.fromJson(Map<String, dynamic> json) {
    return ProjectFinancials(
      totalContractValue: json['total_contract_value'] as num? ?? 0,
      totalEarned: json['total_earned'] as num? ?? 0,
      totalPaid: json['total_paid'] as num? ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }
}
