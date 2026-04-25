import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team_member.dart';
import '../models/invite_member_payload.dart';
import '../models/team_responses.dart';
import '../repositories/team_repository.dart';

final teamMembersProvider = FutureProvider.family<TeamMembersResponse, ({String? projectId, int page, int perPage})>((ref, args) async {
  final repository = ref.read(teamRepositoryProvider);
  return repository.fetchTeamMembers(
    projectId: args.projectId,
    page: args.page,
    perPage: args.perPage,
  );
});

final teamMemberDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final repository = ref.read(teamRepositoryProvider);
  return repository.fetchTeamMember(id);
});

class TeamNotifier extends AsyncNotifier<void> {
  late TeamRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(teamRepositoryProvider);
  }

  Future<void> inviteMember(InviteMemberPayload payload) async {
    state = const AsyncLoading();
    try {
      await _repository.inviteTeamMember(payload);
      state = const AsyncData(null);
      // Invalidate relevant queries
      ref.invalidate(teamMembersProvider);
    } catch (e, st) {
      // Check if the error is due to user already having an account
      final errorStr = e.toString().toLowerCase();
      final isExistingMemberError = errorStr.contains('already has an account') ||
          errorStr.contains('already exists') ||
          errorStr.contains('already a member') ||
          errorStr.contains('email already') ||
          errorStr.contains('user already') ||
          errorStr.contains('account already');
      
      if (isExistingMemberError) {
        // Fallback: add existing member directly
        try {
          await _repository.addExistingMember(payload);
          state = const AsyncData(null);
          ref.invalidate(teamMembersProvider);
          return;
        } catch (fallbackError, fallbackSt) {
          state = AsyncError(fallbackError, fallbackSt);
          rethrow;
        }
      }
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> removeMember(String memberId) async {
    state = const AsyncLoading();
    try {
      await _repository.removeTeamMember(memberId);
      state = const AsyncData(null);
      ref.invalidate(teamMembersProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<String> _resolveProjectMemberId(TeamMember member) async {
    final candidateUserId = member.user?.id ?? member.userId ?? member.id;
    final teamResponse = await _repository.fetchTeamMembers();
    
    for (var teamMember in teamResponse.data) {
      final teamUserId = teamMember.user?.id ?? teamMember.userId;
      if (teamUserId == candidateUserId) {
        if (teamMember.id.isEmpty) {
          throw Exception('Unable to resolve team member ID for project removal');
        }
        return teamMember.id;
      }
    }
    
    throw Exception('Unable to resolve team member ID for project removal');
  }

  Future<void> removeProjectMember(String projectId, TeamMember member) async {
    state = const AsyncLoading();
    try {
      final resolvedMemberId = await _resolveProjectMemberId(member);
      await _repository.removeProjectTeamMember(projectId, resolvedMemberId);
      state = const AsyncData(null);
      ref.invalidate(teamMembersProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> assignProjectMember(String projectId, String teamMemberId) async {
    state = const AsyncLoading();
    try {
      await _repository.assignProjectTeamMember(projectId, teamMemberId);
      state = const AsyncData(null);
      ref.invalidate(teamMembersProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<dynamic> exportTeamMembers() async {
    state = const AsyncLoading();
    try {
      final result = await _repository.exportTeamMembers();
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final teamActionProvider = AsyncNotifierProvider<TeamNotifier, void>(TeamNotifier.new);
