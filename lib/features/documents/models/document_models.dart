class ProjectDocument {
  final String id;
  final String name;
  final String type;
  final String? url;
  final String? createdAt;
  final int? size;
  final Map<String, dynamic> rawData;

  ProjectDocument({
    required this.id,
    required this.name,
    required this.type,
    this.url,
    this.createdAt,
    this.size,
    required this.rawData,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Document',
      type: json['type']?.toString() ?? 'other',
      url: json['url']?.toString(),
      createdAt: json['created_at']?.toString(),
      size: json['size'] as int?,
      rawData: json,
    );
  }

  String get formattedSize {
    if (size == null) return '';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class UploadDocumentPayload {
  final String filePath; // Absolute local file path representing the File blob
  final String type;
  final String? name;

  UploadDocumentPayload({
    required this.filePath,
    required this.type,
    this.name,
  });
}

class DocumentsResponse {
  final bool status;
  final String message;
  final List<ProjectDocument> data;

  DocumentsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return DocumentsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataList.map((e) => ProjectDocument.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
