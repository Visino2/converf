class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;
  bool get isUnread => !isRead;
  bool get isMessageNotification {
    final normalizedType = type.toLowerCase();
    if (normalizedType.contains('message') ||
        normalizedType.contains('chat') ||
        normalizedType.contains('conversation')) {
      return true;
    }

    final category = _firstNonEmptyOrNull([
      data['category'],
      data['event'],
      data['notification_type'],
      data['resource_type'],
    ]);

    if (category == null) {
      return projectId != null && messageId != null;
    }

    final normalizedCategory = category.toLowerCase();
    return normalizedCategory.contains('message') ||
        normalizedCategory.contains('chat') ||
        normalizedCategory.contains('conversation');
  }

  String? get projectId => _firstNonEmptyOrNull([
    data['project_id'],
    data['projectId'],
    if (data['project'] is Map) (data['project'] as Map)['id'],
  ]);

  String? get messageId => _firstNonEmptyOrNull([
    data['message_id'],
    data['messageId'],
    if (data['message'] is Map) (data['message'] as Map)['id'],
  ]);

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map<String, dynamic>)
        : <String, dynamic>{};

    final normalizedPayload = <String, dynamic>{
      ...payload,
      if (!payload.containsKey('project_id') && json.containsKey('project_id'))
        'project_id': json['project_id'],
      if (!payload.containsKey('message_id') && json.containsKey('message_id'))
        'message_id': json['message_id'],
    };

    final type = _firstNonEmptyString([
      json['type'],
      normalizedPayload['type'],
    ], fallback: 'notification');

    return AppNotification(
      id: _firstNonEmptyString([json['id'], payload['id']], fallback: ''),
      type: type,
      title: _firstNonEmptyString([
        json['title'],
        payload['title'],
        payload['subject'],
        _humanizeType(type),
      ], fallback: 'Notification'),
      body: _firstNonEmptyString([
        json['body'],
        json['message'],
        normalizedPayload['body'],
        normalizedPayload['message'],
        normalizedPayload['text'],
        normalizedPayload['content'],
      ], fallback: 'You have a new notification.'),
      data: normalizedPayload,
      createdAt: _parseDateTime(
        json['created_at'] ?? normalizedPayload['created_at'],
      ),
      readAt: _parseDateTime(json['read_at'] ?? normalizedPayload['read_at']),
    );
  }

  static String _firstNonEmptyString(
    List<dynamic> values, {
    required String fallback,
  }) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static String? _firstNonEmptyOrNull(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static String _humanizeType(String type) {
    final raw = type.contains('.') ? type.split('.').last : type;
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment[0].toUpperCase() + segment.substring(1))
        .join(' ');
  }
}

class NotificationsResponse {
  final bool status;
  final String message;
  final List<AppNotification> data;

  const NotificationsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    final List<dynamic> items;

    if (rawData is List<dynamic>) {
      items = rawData;
    } else if (rawData is Map<String, dynamic> &&
        rawData['data'] is List<dynamic>) {
      items = rawData['data'] as List<dynamic>;
    } else {
      items = const [];
    }

    return NotificationsResponse(
      status: json['status'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      data: items
          .whereType<Map>()
          .map(
            (item) => AppNotification.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}

class RegisterDeviceTokenPayload {
  final String token;
  final String platform;

  const RegisterDeviceTokenPayload({
    required this.token,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {'token': token, 'platform': platform};
}
