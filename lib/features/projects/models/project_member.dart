import '../../team/models/team_member.dart';

class ProjectMember {
  final String id;
  final String? teamMemberId;
  final TeamMember? teamMember;
  final String? role;
  final DateTime? createdAt;

  ProjectMember({
    required this.id,
    this.teamMemberId,
    this.teamMember,
    this.role,
    this.createdAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id']?.toString() ?? '',
      teamMemberId: json['team_member_id']?.toString(),
      teamMember: json['team_member'] != null
          ? TeamMember.fromJson(json['team_member'])
          : null,
      role: json['role']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_member_id': teamMemberId,
      'team_member': teamMember?.id, 
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper getters to simplify UI access
  String get displayName => teamMember?.displayName ?? 'Unknown Member';
  String get displayRole => role ?? teamMember?.role ?? 'Member';
  String? get avatarUrl => teamMember?.user?.avatar;
}

class ProjectMemberListResponse {
  final bool status;
  final String message;
  final List<ProjectMember> data;

  ProjectMemberListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProjectMemberListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectMemberListResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ProjectMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
