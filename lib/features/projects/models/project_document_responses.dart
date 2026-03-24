import 'project_document.dart';

class ProjectDocumentResponse {
  final ProjectDocument data;

  ProjectDocumentResponse({required this.data});

  factory ProjectDocumentResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDocumentResponse(
      data: ProjectDocument.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class ProjectDocumentListResponse {
  final List<ProjectDocument> data;

  ProjectDocumentListResponse({required this.data});

  factory ProjectDocumentListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDocumentListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ProjectDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
