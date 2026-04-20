import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'project_image.dart';
import '../../messages/models/message.dart';

// Helper for safely parsing numbers from dynamic API responses
num? _parseNum(dynamic value, [String? fieldName]) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  if (value is Map) {
    if (value.isEmpty) return null;
    debugPrint('DEBUG: field $fieldName expected num? but got Map: $value');
    if (value.containsKey('amount')) {
      return _parseNum(value['amount'], fieldName);
    }
    if (value.containsKey('value')) {
      return _parseNum(value['value'], fieldName);
    }
    if (value.containsKey('id')) {
      return _parseNum(value['id'], fieldName);
    }
  }
  return null;
}

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

  Color get bgColor {
    switch (this) {
      case ProjectStatus.active:
        return const Color(0xFFECFDF3); // Green bg
      case ProjectStatus.completed:
        return const Color(0xFFF2F4F7); // Gray bg
      case ProjectStatus.atRisk:
      case ProjectStatus.delayed:
      case ProjectStatus.cancelled:
        return const Color(0xFFFEF3F2); // Red bg
      case ProjectStatus.pendingTender:
      case ProjectStatus.onHold:
        return const Color(0xFFFFFAEB); // Orange bg
      default:
        return const Color(0xFFF9FAFB);
    }
  }

  Color get textColor {
    switch (this) {
      case ProjectStatus.active:
        return const Color(0xFF027A48); // Green text
      case ProjectStatus.completed:
        return const Color(0xFF344054); // Gray text
      case ProjectStatus.atRisk:
      case ProjectStatus.delayed:
      case ProjectStatus.cancelled:
        return const Color(0xFFB42318); // Red text
      case ProjectStatus.pendingTender:
      case ProjectStatus.onHold:
        return const Color(0xFFB54708); // Orange text
      default:
        return const Color(0xFF475467);
    }
  }
}

enum UrgencyLevel {
  low,
  medium,
  high,
  critical;

  String toJson() => name;

  static UrgencyLevel fromString(String urgency) {
    return UrgencyLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == urgency.toLowerCase(),
      orElse: () => UrgencyLevel.medium,
    );
  }

  Color get bgColor {
    switch (this) {
      case UrgencyLevel.critical:
        return const Color(0xFFFEE4E2);
      case UrgencyLevel.high:
        return const Color(0xFFFFEDD5);
      case UrgencyLevel.medium:
        return const Color(0xFFDBEAFE);
      case UrgencyLevel.low:
        return const Color(0xFFF3F4F6);
    }
  }

  Color get textColor {
    switch (this) {
      case UrgencyLevel.critical:
        return const Color(0xFF7F1D1D);
      case UrgencyLevel.high:
        return const Color(0xFF7F1D1D);
      case UrgencyLevel.medium:
        return const Color(0xFF1E3A8A);
      case UrgencyLevel.low:
        return const Color(0xFF111827);
    }
  }
}

class ProjectParty {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? companyName;
  final String? avatar;
  final String? avatarUrl;

  ProjectParty({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.companyName,
    this.avatar,
    this.avatarUrl,
  });

  factory ProjectParty.fromJson(Map<String, dynamic> json) {
    // Web API can have company_name at top level or inside profile
    String? companyName = json['company_name']?.toString();
    if (companyName == null && json['profile'] is Map) {
      companyName = (json['profile'] as Map<String, dynamic>)['company_name']
          ?.toString();
    }
    if (companyName == null && json['contractor_profile'] is Map) {
      companyName =
          (json['contractor_profile'] as Map<String, dynamic>)['company_name']
              ?.toString();
    }

    return ProjectParty(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      companyName: companyName,
      avatar: ProjectImage.normalizeImageUrl(
        json['avatar']?.toString(),
        timestamp: json['updated_at']?.toString(),
      ),
      avatarUrl: ProjectImage.normalizeImageUrl(
        json['avatar_url']?.toString(),
        timestamp: json['updated_at']?.toString(),
      ),
    );
  }

  String get displayName => companyName != null && companyName!.isNotEmpty
      ? companyName!
      : '$firstName $lastName'.trim().isEmpty
      ? 'Unknown'
      : '$firstName $lastName'.trim();
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
  final UrgencyLevel urgencyLevel;
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
  final String? coverImage;
  final List<ProjectImage> coverImages;
  final Message? latestMessage;
  final double? siteLatitude;
  final double? siteLongitude;
  final int? siteGeofenceRadiusM;

  String get daysRemaining {
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = end.difference(now).inDays;
      if (difference <= 0) return 'Due';
      return '$difference days left';
    } catch (e) {
      return '--';
    }
  }

  String get formattedLocation {
    String formatSegment(String? value) {
      if (value == null || value.isEmpty) return '';
      return value
          .split(' ')
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '',
          )
          .join(' ');
    }

    final segments = [
      city,
      state,
      country,
    ].map(formatSegment).where((s) => s.isNotEmpty).toList();
    return segments.isNotEmpty
        ? segments.join(', ')
        : (location.isNotEmpty ? location : 'Location N/A');
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
    this.coverImage,
    List<ProjectImage>? coverImages,
    this.latestMessage,
    this.siteLatitude,
    this.siteLongitude,
    this.siteGeofenceRadiusM,
  }) : coverImages = coverImages ?? [];

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      constructionType: json['construction_type']?.toString() ?? '',
      status: ProjectStatus.fromString(json['status']?.toString() ?? ''),
      currentStep:
          _parseNum(json['current_step'], 'current_step')?.toInt() ?? 1,
      isBookmarked: json['is_bookmarked'] == true,
      budget: json['budget']?.toString() ?? '0',
      currency: json['currency']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      urgencyLevel: UrgencyLevel.fromString(
        json['urgency_level']?.toString() ?? 'medium',
      ),
      assignmentMethod: json['assignment_method']?.toString() ?? '',
      biddingDeadline: json['bidding_deadline']?.toString(),
      bidsCount: _parseNum(json['bids_count'], 'bids_count')?.toInt(),
      contractorId: json['contractor_id']?.toString(),
      contractor: json['contractor'] is Map<String, dynamic>
          ? ProjectParty.fromJson(json['contractor'] as Map<String, dynamic>)
          : null,
      owner: json['owner'] is Map<String, dynamic>
          ? ProjectParty.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      matchRate: _parseNum(json['match_rate'], 'match_rate'),
      constructionSubType: json['construction_sub_type']?.toString(),
      specialisations:
          (json['specialisations'] as List<dynamic>?)
              ?.map(
                (e) =>
                    (e is Map
                        ? e['specialisation']?.toString()
                        : e.toString()) ??
                    '',
              )
              .where((s) => s.isNotEmpty)
              .cast<String>()
              .toList() ??
          [],
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
      coverImage: ProjectImage.normalizeImageUrl(
        json['cover_image']?.toString() ?? json['thumbnail']?.toString(),
        timestamp: json['updated_at']?.toString(),
      ),
      coverImages:
          (json['cover_images'] as List<dynamic>?)
              ?.map((e) => ProjectImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      latestMessage: json['latest_message'] != null
          ? Message.fromJson(json['latest_message'] as Map<String, dynamic>)
          : null,
      siteLatitude: _parseNum(
        json['site_latitude'],
        'site_latitude',
      )?.toDouble(),
      siteLongitude: _parseNum(
        json['site_longitude'],
        'site_longitude',
      )?.toDouble(),
      siteGeofenceRadiusM: _parseNum(
        json['site_geofence_radius_m'],
        'site_geofence_radius_m',
      )?.toInt(),
    );
  }
}

class ProjectFinancials {
  final num? totalContractValue;
  final num totalEarned;
  final num totalPaid;
  final String? currency;

  ProjectFinancials({
    this.totalContractValue,
    required this.totalEarned,
    required this.totalPaid,
    this.currency,
  });

  bool get hasContractValue =>
      totalContractValue != null && totalContractValue! > 0;

  String formattedContractValue(String fallbackCurrency) {
    final cur = (currency != null && currency!.isNotEmpty)
        ? currency!
        : fallbackCurrency;
    final symbol = cur == 'NGN' ? '₦' : (cur == 'USD' ? '\$' : cur);
    final val = totalContractValue ?? 0;

    if (val >= 1000000) {
      return '$symbol ${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '$symbol ${(val / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol $val';
  }

  String formattedEarnedValue(String fallbackCurrency) {
    final cur = (currency != null && currency!.isNotEmpty)
        ? currency!
        : fallbackCurrency;
    final symbol = cur == 'NGN' ? '₦' : (cur == 'USD' ? '\$' : cur);

    if (totalEarned >= 1000000) {
      return '$symbol ${(totalEarned / 1000000).toStringAsFixed(1)}M';
    } else if (totalEarned >= 1000) {
      return '$symbol ${(totalEarned / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol $totalEarned';
  }

  String formattedPaidValue(String fallbackCurrency) {
    final cur = (currency != null && currency!.isNotEmpty)
        ? currency!
        : fallbackCurrency;
    final symbol = cur == 'NGN' ? '₦' : (cur == 'USD' ? '\$' : cur);

    if (totalPaid >= 1000000) {
      return '$symbol ${(totalPaid / 1000000).toStringAsFixed(1)}M';
    } else if (totalPaid >= 1000) {
      return '$symbol ${(totalPaid / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol $totalPaid';
  }

  int get budgetUtilizedPercentage =>
      (totalContractValue != null && totalContractValue! > 0)
      ? ((totalEarned / totalContractValue!) * 100).toInt()
      : 0;

  factory ProjectFinancials.fromJson(Map<String, dynamic> json) {
    return ProjectFinancials(
      totalContractValue: _parseNum(
        json['total_contract_value'],
        'total_contract_value',
      ),
      totalEarned: _parseNum(json['total_earned'], 'total_earned') ?? 0,
      totalPaid: _parseNum(json['total_paid'], 'total_paid') ?? 0,
      currency: json['currency'] as String?,
    );
  }
}
