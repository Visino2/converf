import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milestone.dart';
import 'project_providers.dart';
import '../../../core/api/api_client.dart';

final projectMilestonesProvider = FutureProvider.family<List<ProjectMilestone>, String>((ref, projectId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/api/v1/projects/$projectId/milestones');
  
  if (response.statusCode == 200) {
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((e) => ProjectMilestone.fromJson(e as Map<String, dynamic>)).toList();
  } else {
    throw Exception(response.data['message'] ?? 'Failed to load project milestones');
  }
});

final allContractorMilestonesProvider = FutureProvider<List<MilestoneWithProject>>((ref) async {
  // 1. Get assigned projects
  final projectsResponse = await ref.watch(assignedProjectsProvider(1).future);
  final projects = projectsResponse.data;
  
  // 2. Fetch milestones for each project and group
  final List<MilestoneWithProject> enrichedMilestones = [];
  
  for (final project in projects) {
    try {
      final milestones = await ref.watch(projectMilestonesProvider(project.id).future);
      for (final m in milestones) {
        enrichedMilestones.add(MilestoneWithProject(
          milestone: m,
          projectName: project.title,
          projectLocation: project.location,
          projectImage: project.coverImage,
        ));
      }
    } catch (e) {
      // Skip projects that fail to load milestones
      continue;
    }
  }
  
  return enrichedMilestones;
});

class MilestoneActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> approveMilestone(String projectId, String milestoneId) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.patch('/api/v1/projects/$projectId/milestones/$milestoneId/approve', data: {});
      
      if (response.statusCode == 200) {
        ref.invalidate(projectMilestonesProvider(projectId));
        state = const AsyncValue.data(null);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to approve milestone');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> declineMilestone(String projectId, String milestoneId, String reason) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.patch('/api/v1/projects/$projectId/milestones/$milestoneId/decline', data: {
        'reason': reason,
      });
      
      if (response.statusCode == 200) {
        ref.invalidate(projectMilestonesProvider(projectId));
        state = const AsyncValue.data(null);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to decline milestone');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final milestoneActionProvider = AsyncNotifierProvider<MilestoneActionNotifier, void>(
  () => MilestoneActionNotifier(),
);
