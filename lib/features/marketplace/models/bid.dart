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
  final String? duration;
  final String? paymentPreference;
  final List<dynamic>? milestones;
  final List<String>? equipment;
  final List<BidDocument>? documents;

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
    this.duration,
    this.paymentPreference,
    this.milestones,
    this.equipment,
    this.documents,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id']?.toString() ?? '',
      amount: num.tryParse(json['amount']?.toString() ?? '0') ?? 0,
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
      duration: json['duration'] as String?,
      paymentPreference: json['payment_preference'] as String?,
      milestones: json['milestones'] as List<dynamic>?,
      equipment: (json['equipment'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => BidDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BidDocument {
  final String id;
  final String name;
  final String url;

  BidDocument({required this.id, required this.name, required this.url});

  factory BidDocument.fromJson(Map<String, dynamic> json) {
    return BidDocument(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Document',
      url: json['url'] as String? ?? '',
    );
  }
}
