import '../../projects/models/project_responses.dart';
import 'bid.dart';

class PaginatedBidsResponse {
  final bool status;
  final String message;
  final List<Bid> data;
  final PaginationMeta? meta;

  PaginatedBidsResponse({
    required this.status,
    required this.message,
    required this.data,
    this.meta,
  });

  factory PaginatedBidsResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataField = json['data'];
    List<dynamic> dataList = [];
    PaginationMeta? metaData;

    if (dataField is Map<String, dynamic>) {
      if (dataField.containsKey('data')) {
        dataList = dataField['data'] as List<dynamic>? ?? [];
      }
      metaData = dataField['meta'] != null
          ? PaginationMeta.fromJson(dataField['meta'] as Map<String, dynamic>)
          : null;
    } else if (dataField is List<dynamic>) {
      dataList = dataField;
      metaData = json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null;
    }

    return PaginatedBidsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: dataList
          .map((e) => Bid.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: metaData,
    );
  }
}

class BidResponse {
  final bool status;
  final String message;
  final Bid? data;

  BidResponse({required this.status, required this.message, this.data});

  factory BidResponse.fromJson(Map<String, dynamic> json) {
    return BidResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? Bid.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BookmarkResponse {
  final bool status;
  final String message;
  final bool isBookmarked;

  BookmarkResponse({
    required this.status,
    required this.message,
    required this.isBookmarked,
  });

  factory BookmarkResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BookmarkResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      isBookmarked: data['is_bookmarked'] as bool? ?? false,
    );
  }
}

class SubmitBidPayload {
  final double amount;
  final String proposal;
  final String? scheduleId;
  final String? duration;
  final String? paymentPreference;
  final List<Map<String, dynamic>>? milestones;
  final List<String>? teamMembers;
  final List<String>? equipment;
  final List<String>? portfolioProjects;
  final List<Map<String, dynamic>>? certifications;
  final List<String>? documentPaths;

  const SubmitBidPayload({
    required this.amount,
    required this.proposal,
    this.scheduleId,
    this.duration,
    this.paymentPreference,
    this.milestones,
    this.teamMembers,
    this.equipment,
    this.portfolioProjects,
    this.certifications,
    this.documentPaths,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'proposal': proposal,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (duration != null) 'duration': duration,
      if (paymentPreference != null) 'payment_preference': paymentPreference,
      if (milestones != null) 'milestones': milestones,
      if (teamMembers != null) 'team_members': teamMembers,
      if (equipment != null) 'equipment': equipment,
      if (portfolioProjects != null) 'portfolio_projects': portfolioProjects,
      if (certifications != null) 'certifications': certifications,
    };
  }
}
