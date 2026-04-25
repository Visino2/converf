import 'project.dart';

// Helper for safely parsing numbers from dynamic API responses
num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
    );
  }
}

class PaginatedProjectsResponse {
  final bool status;
  final String message;
  final List<Project> data;
  final PaginationMeta? meta;

  PaginatedProjectsResponse({
    required this.status,
    required this.message,
    required this.data,
    this.meta,
  });

  factory PaginatedProjectsResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested format often seen in Laravel paginators (data.data)
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

    return PaginatedProjectsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: dataList
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: metaData,
    );
  }
}

class ProjectResponse {
  final bool status;
  final String message;
  final Project? data;

  ProjectResponse({required this.status, required this.message, this.data});

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? Project.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WizardResponse {
  final bool status;
  final String message;
  final String id;
  final int currentStep;
  final Project? project;

  WizardResponse({
    required this.status,
    required this.message,
    required this.id,
    required this.currentStep,
    this.project,
  });

  factory WizardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

    // Look for ID in multiple possible locations
    final String id =
        (data?['id'] ??
                data?['project_id'] ??
                data?['uuid'] ??
                (data?['project'] as Map?)?['id'] ??
                json['id'] ??
                json['project_id'] ??
                json['uuid'] ??
                '')
            .toString();

    return WizardResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      id: id,
      currentStep:
          _parseNum(data?['current_step'] ?? json['current_step'])?.toInt() ??
          0,
      project: data?['project'] != null
          ? Project.fromJson(data!['project'] as Map<String, dynamic>)
          : null,
    );
  }
}
