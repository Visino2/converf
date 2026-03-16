import '../../projects/models/project.dart';

class Bid {
  final String id;
  final num amount;
  final String proposal;
  final String status;
  final String projectId;
  final String contractorId;
  final String createdAt;
  final String? updatedAt;
  final ProjectParty? contractor;
  final Project? project;

  Bid({
    required this.id,
    required this.amount,
    required this.proposal,
    required this.status,
    required this.projectId,
    required this.contractorId,
    required this.createdAt,
    this.updatedAt,
    this.contractor,
    this.project,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] as num? ?? 0,
      proposal: json['proposal'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      projectId: json['project_id']?.toString() ?? '',
      contractorId: json['contractor_id']?.toString() ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
      contractor: json['contractor'] != null
          ? ProjectParty.fromJson(json['contractor'] as Map<String, dynamic>)
          : null,
      project: json['project'] != null
          ? Project.fromJson(json['project'] as Map<String, dynamic>)
          : null,
    );
  }
}
