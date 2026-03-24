import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/project_member.dart';

final projectTeamRepositoryProvider = Provider<ProjectTeamRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProjectTeamRepository(ApiClient(dio));
});

class ProjectTeamRepository {
  final ApiClient _apiClient;

  ProjectTeamRepository(this._apiClient);

  Future<ProjectMemberListResponse> fetchTeamMembers(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/team');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectMemberListResponse.fromJson(response.data);
  }

  Future<void> assignMember(String projectId, String teamMemberId) async {
    await _apiClient.post(
      '/api/v1/projects/$projectId/team',
      data: {'team_member_id': teamMemberId},
    );
  }

  Future<void> removeMember(String projectId, String memberId) async {
    await _apiClient.delete('/api/v1/projects/$projectId/team/$memberId');
  }
}
