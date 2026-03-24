import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_provider.dart';
import '../../../core/api/api_client.dart';
import '../models/invite_member_payload.dart';
import '../models/team_responses.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TeamRepository(ApiClient(dio));
});

class TeamRepository {
  final ApiClient _apiClient;

  TeamRepository(this._apiClient);

  Future<TeamMembersResponse> fetchTeamMembers({String? projectId, int page = 1, int perPage = 15}) async {
    final url = projectId != null ? '/api/v1/projects/$projectId/team' : '/api/v1/team';
    final response = await _apiClient.get(
      url,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return TeamMembersResponse.fromJson(response.data);
  }

  Future<Map<String, dynamic>> fetchTeamMember(String memberId) async {
    final response = await _apiClient.get('/api/v1/team/$memberId');
    return response.data as Map<String, dynamic>;
  }

  Future<void> removeTeamMember(String memberId) async {
    await _apiClient.delete('/api/v1/team/$memberId');
  }

  Future<void> removeProjectTeamMember(String projectId, String memberId) async {
    await _apiClient.delete('/api/v1/projects/$projectId/team/$memberId');
  }

  Future<void> assignProjectTeamMember(String projectId, String teamMemberId) async {
    await _apiClient.post('/api/v1/projects/$projectId/team', data: {
      'team_member_id': teamMemberId,
    });
  }

  Future<void> inviteTeamMember(InviteMemberPayload payload) async {
    await _apiClient.post('/api/v1/team/invitations', data: payload.toJson());
  }

  Future<dynamic> exportTeamMembers() async {
    final response = await _apiClient.get('/api/v1/team/export');
    return response.data;
  }
}
