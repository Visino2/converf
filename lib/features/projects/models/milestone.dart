class ProjectMilestone {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final double amount;
  final String status; // 'pending', 'approved', 'declined'
  final String? declinedReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectMilestone({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.dueDate,
    required this.amount,
    required this.status,
    this.declinedReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    // Handle wrap in 'data' field
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return ProjectMilestone(
      id: data['id']?.toString() ?? '',
      projectId: data['project_id']?.toString() ?? '',
      title: data['title'] as String? ?? 'Untitled Milestone',
      description: data['description'] as String?,
      dueDate: data['due_date'] != null ? DateTime.tryParse(data['due_date'] as String) : null,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending',
      declinedReason: data['declined_reason'] as String?,
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at'] as String) : DateTime.now(),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : DateTime.now(),
    );
  }

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isDeclined => status.toLowerCase() == 'declined';
  bool get isPending => status.toLowerCase() == 'pending';
}

class MilestoneWithProject {
  final ProjectMilestone milestone;
  final String projectName;
  final String? projectLocation;
  final String? projectImage;

  MilestoneWithProject({
    required this.milestone,
    required this.projectName,
    this.projectLocation,
    this.projectImage,
  });
}
