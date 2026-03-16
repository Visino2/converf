import 'team_member.dart';

class TeamMembersResponse {
  final bool status;
  final String message;
  final List<TeamMember> data;
  final PaginationMeta? meta;

  TeamMembersResponse({
    required this.status,
    required this.message,
    required this.data,
    this.meta,
  });

  factory TeamMembersResponse.fromJson(Map<String, dynamic> json) {
    return TeamMembersResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => TeamMember.fromJson(e))
          .toList(),
      meta: json['meta'] != null ? PaginationMeta.fromJson(json['meta']) : null,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
    );
  }
}
