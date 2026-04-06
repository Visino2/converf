class MessageSender {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? role;
  final String? avatar;
  final String? avatarUrl;

  MessageSender({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.role,
    this.avatar,
    this.avatarUrl,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] as String? ?? 'Unknown',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String?,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class Message {
  final String id;
  final String body;
  final String? readAt;
  final String createdAt;
  final MessageSender? sender;

  Message({
    required this.id,
    required this.body,
    this.readAt,
    required this.createdAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      sender: json['sender'] != null ? MessageSender.fromJson(json['sender'] as Map<String, dynamic>) : null,
    );
  }
}

class MessageResponse {
  final bool status;
  final String message;
  final List<Message>? data;

  MessageResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json.containsKey('data') && json['data'] != null
          ? (json['data'] as List).map((item) => Message.fromJson(item as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

class SingleMessageResponse {
  final bool status;
  final String message;
  final Message? data;

  SingleMessageResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SingleMessageResponse.fromJson(Map<String, dynamic> json) {
    return SingleMessageResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json.containsKey('data') && json['data'] != null
          ? Message.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
