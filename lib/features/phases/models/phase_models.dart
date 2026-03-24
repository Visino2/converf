class Phase {
  final String id;
  final String name;
  final String status; // pending, in_progress, completed
  final int order;
  final String startDate;
  final String endDate;
  final String? description;
  final Map<String, dynamic> rawData;

  Phase({
    required this.id,
    required this.name,
    required this.status,
    required this.order,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.rawData,
  });

  factory Phase.fromJson(Map<String, dynamic> json) {
    return Phase(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Phase',
      status: json['status']?.toString() ?? 'pending',
      order: json['order'] as int? ?? 0,
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      description: json['description']?.toString(),
      rawData: json,
    );
  }
}

class PhasesResponse {
  final bool status;
  final String message;
  final List<Phase> data;

  PhasesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PhasesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<dynamic> dataList = [];
    if (rawData is List) {
      dataList = rawData;
    } else if (rawData is Map && rawData.containsKey('data')) {
      dataList = rawData['data'] as List<dynamic>;
    }
    return PhasesResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataList.map((e) => Phase.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
