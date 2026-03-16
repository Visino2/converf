enum UserRole {
  projectOwner,
  contractor,
  unknown;

  static UserRole fromString(String? role) {
    if (role == 'project_owner' || role == 'owner') return UserRole.projectOwner;
    if (role == 'contractor') return UserRole.contractor;
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
    return AuthResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }

  UserRole get role => data?.role ?? UserRole.unknown;
}

class AuthData {
  final String token;
  final Map<String, dynamic> user;

  AuthData({
    required this.token,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] ?? '',
      user: json['user'] ?? {},
    );
  }

  UserRole get role => UserRole.fromString(user['role']);
}
