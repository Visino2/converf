class ProjectImage {
  final String id;
  final String projectId;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final String? caption;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectImage({
    required this.id,
    required this.projectId,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    this.caption,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  static String? normalizeImageUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http:https://')) {
      return url.replaceFirst('http:https://', 'https://');
    }
    if (url.startsWith('http:http://')) {
      return url.replaceFirst('http:http://', 'http://');
    }
    return url;
  }

  factory ProjectImage.fromJson(Map<String, dynamic> json) {
    return ProjectImage(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      fileUrl: normalizeImageUrl(json['file_url'] as String?) ?? '',
      fileSize: json['file_size'] as int? ?? 0,
      mimeType: json['mime_type'] as String? ?? '',
      caption: json['caption'] as String?,
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1 || json['is_primary'] == '1',
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
      'file_url': fileUrl,
      'file_size': fileSize,
      'mime_type': mimeType,
      'caption': caption,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ProjectImageListResponse {
  final List<ProjectImage> data;

  ProjectImageListResponse({required this.data});

  factory ProjectImageListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectImageListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ProjectImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
