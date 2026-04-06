enum UserRole {
  projectOwner,
  contractor,
  unknown;

  static UserRole fromString(String? role) {
    if (role == 'project_owner' || role == 'owner') {
      return UserRole.projectOwner;
    }
    if (role == 'contractor') {
      return UserRole.contractor;
    }
    return UserRole.unknown;
  }
}

class AuthResponse {
  final bool status;
  final String message;
  final AuthData? data;
  final dynamic errors;

  AuthResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    AuthData? parsedData;
    if (json['data'] != null) {
      parsedData = AuthData.fromJson(json['data']);
    }
    
    final rootToken = json['token']?.toString() ?? json['access_token']?.toString() ?? '';
    
    if (parsedData != null && parsedData.token.isEmpty && rootToken.isNotEmpty) {
      parsedData = parsedData.copyWith(token: rootToken);
    } else if (parsedData == null && rootToken.isNotEmpty) {
      final userMap = json['user'] ?? json['data']?['user'] ?? <String, dynamic>{};
      parsedData = AuthData(token: rootToken, user: userMap);
    }

    return AuthResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: parsedData,
      errors: json['errors'],
    );
  }

  factory AuthResponse.fromSession({
    required String token,
    required Map<String, dynamic> user,
    String message = 'Session restored',
  }) {
    return AuthResponse(
      status: true,
      message: message,
      data: AuthData(token: token, user: user),
    );
  }

  bool get isAuthenticated {
    return status && data != null && data!.token.isNotEmpty;
  }

  Map<String, dynamic> get user => data?.user ?? const <String, dynamic>{};

  UserRole get role => data?.role ?? UserRole.unknown;

  AuthResponse copyWith({
    bool? status,
    String? message,
    AuthData? data,
    dynamic errors,
  }) {
    return AuthResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      errors: errors ?? this.errors,
    );
  }
}

class AuthData {
  final String token;
  final Map<String, dynamic> user;

  AuthData({required this.token, required this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token']?.toString() ?? json['access_token']?.toString() ?? '',
      user: json['user'] ?? <String, dynamic>{},
    );
  }

  UserRole get role => UserRole.fromString(user['role']);

  AuthData copyWith({String? token, Map<String, dynamic>? user}) {
    return AuthData(token: token ?? this.token, user: user ?? this.user);
  }
}
