class Inspection {
  final String id;
  final String status;
  final String inspectionDate;
  final String summary;
  final String? findings;
  final Map<String, dynamic>? inspector;
  final List<String> images;
  final String? phase;

  Inspection({
    required this.id,
    required this.status,
    required this.inspectionDate,
    required this.summary,
    this.findings,
    this.inspector,
    this.images = const [],
    this.phase,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      inspectionDate: json['inspection_date']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      findings: json['findings']?.toString(),
      inspector: json['inspector'] as Map<String, dynamic>?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      phase: json['phase']?.toString(),
    );
  }
}

class CreateInspectionPayload {
  final String inspectionDate;
  final String summary;
  final String? findings;
  final String? status;
  final String? locationCoordinates;
  final String? phase;
  /// List of absolute file paths to local image files on the device.
  final List<String> images;

  CreateInspectionPayload({
    required this.inspectionDate,
    required this.summary,
    this.findings,
    this.status,
    this.locationCoordinates,
    this.phase,
    this.images = const [],
  });
}

class InspectionsResponse {
  final bool status;
  final String message;
  final List<Inspection> data;

  InspectionsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory InspectionsResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataField = json['data'];
    List<dynamic> dataList = [];

    if (dataField is List<dynamic>) {
      dataList = dataField;
    } else if (dataField is Map<String, dynamic>) {
      // Handle nested data field in paginated responses
      if (dataField.containsKey('data')) {
        dataList = dataField['data'] as List<dynamic>? ?? [];
      }
    }

    return InspectionsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataList.map((e) => Inspection.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
