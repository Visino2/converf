import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_member.dart';
import '../repositories/project_team_repository.dart';

final projectTeamProvider = FutureProvider.family<List<ProjectMember>, String>((ref, projectId) async {
  final repository = ref.read(projectTeamRepositoryProvider);
  final response = await repository.fetchTeamMembers(projectId);
  return response.data;
});

class ProjectTeamNotifier extends AsyncNotifier<void> {
  late ProjectTeamRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(projectTeamRepositoryProvider);
  }

  Future<void> assignMember(String projectId, String teamMemberId) async {
    state = const AsyncLoading();
    try {
      await _repository.assignMember(projectId, teamMemberId);
      state = const AsyncData(null);
      ref.invalidate(projectTeamProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> removeMember(String projectId, String memberId) async {
    state = const AsyncLoading();
    try {
      await _repository.removeMember(projectId, memberId);
      state = const AsyncData(null);
      ref.invalidate(projectTeamProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final projectTeamNotifierProvider = AsyncNotifierProvider<ProjectTeamNotifier, void>(ProjectTeamNotifier.new);
