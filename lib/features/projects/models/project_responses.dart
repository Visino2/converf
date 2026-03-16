import 'project.dart';

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
      data: dataList.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList(),
      meta: metaData,
    );
  }
}

class ProjectResponse {
  final bool status;
  final String message;
  final Project? data;

  ProjectResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? Project.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}

class WizardResponse {
  final bool status;
  final String message;
  final int currentStep;
  final Project? project;

  WizardResponse({
    required this.status,
    required this.message,
    required this.currentStep,
    this.project,
  });

  factory WizardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return WizardResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      currentStep: data['current_step'] as int? ?? 1,
      project: data['project'] != null ? Project.fromJson(data['project'] as Map<String, dynamic>) : null,
    );
  }
}
