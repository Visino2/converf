import '../../auth/models/auth_response.dart';

class TeamMember {
  final String id;
  final String? userId;
  final TeamMemberUser? user;
  final String role;
  final String status;
  final String? joinedAt;

  TeamMember({
    required this.id,
    this.userId,
    this.user,
    required this.role,
    required this.status,
    this.joinedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      user: json['user'] != null
          ? TeamMemberUser.fromJson(json['user'])
          : null,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      joinedAt: json['joined_at'],
    );
  }

  String get displayName {
    if (user != null) {
      return '${user!.firstName} ${user!.lastName}';
    }
    return 'Member $id';
  }
}

class TeamMemberUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;

  TeamMemberUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
  });

  factory TeamMemberUser.fromJson(Map<String, dynamic> json) {
    return TeamMemberUser(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
    );
  }
}
