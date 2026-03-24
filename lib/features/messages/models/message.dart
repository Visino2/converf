class MessageSender {
  final String id;
  final String first_name;
  final String last_name;
  final String? email;
  final String? role;
  final String? avatar;
  final String? avatar_url;

  MessageSender({
    required this.id,
    required this.first_name,
    required this.last_name,
    this.email,
    this.role,
    this.avatar,
    this.avatar_url,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'] as String,
      first_name: json['first_name'] as String? ?? 'Unknown',
      last_name: json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String?,
      avatar: json['avatar'] as String?,
      avatar_url: json['avatar_url'] as String?,
    );
  }
}

class Message {
  final String id;
  final String body;
  final String? read_at;
  final String created_at;
  final MessageSender? sender;

  Message({
    required this.id,
    required this.body,
    this.read_at,
    required this.created_at,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      read_at: json['read_at'] as String?,
      created_at: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
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
