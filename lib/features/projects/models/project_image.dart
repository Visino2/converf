import '../../../core/config/config.dart';

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

  static String? normalizeImageUrl(String? url, {String? timestamp}) {
    if (url == null || url.trim().isEmpty) return null;

    String normalized = url.trim();
    // Fix double-protocol bugs (e.g. 'http:https://' or 'https://https://')
    normalized = normalized.replaceFirstMapped(
      RegExp(r'^https?:\/*(https?://)', caseSensitive: false),
      (m) => m.group(1)!,
    );
    // Fix malformed external URLs wrapped in storage path
    // e.g. 'https://api.example.com/storage/https://cdn.example.com/image.jpg'
    final nestedUrlMatch = RegExp(
      r'/storage/(https?://.+)$',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (nestedUrlMatch != null) {
      return nestedUrlMatch.group(1)!;
    }

    String? finalUrl;
    // If it's a relative path, prefix with the API base URL
    if (!normalized.startsWith('http')) {
      final baseUrl = AppConfig.apiBaseUrl;
      if (normalized.startsWith('/')) {
        finalUrl = '$baseUrl$normalized';
      } else {
        finalUrl = '$baseUrl/storage/$normalized';
      }
    } else {
      finalUrl = normalized;
    }

    if (timestamp != null && timestamp.isNotEmpty) {
      final separator = finalUrl.contains('?') ? '&' : '?';
      // Use hash of timestamp to keep URL clean but unique
      finalUrl = '$finalUrl${separator}t=${timestamp.hashCode}';
    }

    return finalUrl;
  }

  factory ProjectImage.fromJson(Map<String, dynamic> json) {
    // API returns either 'file_url' (images endpoint) or 'url' (thumbnail/cover_images)
    final rawUrl = (json['file_url'] ?? json['url'])?.toString();
    return ProjectImage(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      fileUrl: normalizeImageUrl(rawUrl) ?? '',
      fileSize: json['file_size'] as int? ?? 0,
      mimeType: json['mime_type'] as String? ?? '',
      caption: json['caption'] as String?,
      isPrimary:
          json['is_primary'] == true ||
          json['is_primary'] == 1 ||
          json['is_primary'] == '1',
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
    // Handles both:
    //   /images endpoint  → {"data": [...]}
    //   /thumbnail endpoint → {"data": {"cover_images": [...]}}
    final dynamic raw = json['data'];
    List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map) {
      items = (raw['cover_images'] as List<dynamic>?) ?? [];
    } else {
      items = [];
    }
    return ProjectImageListResponse(
      data: items
          .map((e) => ProjectImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((e) => e.toJson()).toList()};
  }
}
