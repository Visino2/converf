import 'project.dart';

class Bid {
  final String id;
  final String projectId;
  final ProjectParty? contractor;
  final String amount;
  final String proposal;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bid({
    required this.id,
    required this.projectId,
    this.contractor,
    required this.amount,
    required this.proposal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      contractor: json['contractor'] != null
          ? ProjectParty.fromJson(json['contractor'] as Map<String, dynamic>)
          : null,
      amount: json['amount']?.toString() ?? '0',
      proposal: json['proposal']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'amount': amount,
      'proposal': proposal,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class BidListResponse {
  final bool status;
  final String message;
  final List<Bid> data;

  BidListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BidListResponse.fromJson(Map<String, dynamic> json) {
    return BidListResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Bid.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BidResponse {
  final bool status;
  final String message;
  final Bid data;

  BidResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BidResponse.fromJson(Map<String, dynamic> json) {
    return BidResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: Bid.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
