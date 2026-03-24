class Milestone {
  final String id;
  final String title;
  final String status; // pending, in_progress, overdue, completed
  final String? dueDate;
  final String? completedAt;
  final String? description;
  final Map<String, dynamic> rawData;

  Milestone({
    required this.id,
    required this.title,
    required this.status,
    this.dueDate,
    this.completedAt,
    this.description,
    required this.rawData,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unnamed Milestone',
      status: json['status']?.toString() ?? 'pending',
      dueDate: json['due_date']?.toString(),
      completedAt: json['completed_at']?.toString(),
      description: json['description']?.toString(),
      rawData: json,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isOverdue => status == 'overdue';
  bool get isInProgress => status == 'in_progress';
}

class MilestonesResponse {
  final bool status;
  final String message;
  final List<Milestone> data;

  MilestonesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MilestonesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<dynamic> dataList = [];
    if (rawData is List) {
      dataList = rawData;
    } else if (rawData is Map && rawData.containsKey('data')) {
      dataList = rawData['data'] as List<dynamic>;
    }
    return MilestonesResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataList.map((e) => Milestone.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
