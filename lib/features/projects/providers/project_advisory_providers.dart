import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../models/project_advisory.dart';
import '../repositories/project_repository.dart';

/// Fetches the AI Advisory for a specific project
final projectAdvisoryProvider = FutureProvider.autoDispose.family<ProjectAdvisoryResponse, String>((ref, projectId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.fetchProjectAdvisory(projectId);
});

/// Fetches the AI Health Score for a specific project
final projectHealthScoreProvider = FutureProvider.autoDispose.family<ProjectAdvisoryResponse, String>((ref, projectId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.fetchProjectHealthScore(projectId);
});

/// Identifies the "most critical" project from the list of active projects
/// and fetches its advisory for the dashboard.
final dashboardAdvisoryProvider = FutureProvider.autoDispose<ProjectAdvisoryResponse?>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  
  // 1. Fetch all projects (we limit to page 1 for the dashboard)
  final projectsResp = await repository.fetchProjects(page: 1);
  final projects = projectsResp.data ?? [];
  
  if (projects.isEmpty) return null;

  // 2. Prioritize projects by status
  // At Risk > Delayed > Active/On Track
  final atRisk = projects.where((p) => p.status == ProjectStatus.atRisk).toList();
  final delayed = projects.where((p) => p.status == ProjectStatus.delayed).toList();
  final others = projects.where((p) => p.status == ProjectStatus.active || p.status == ProjectStatus.onTrack).toList();

  String targetId;
  if (atRisk.isNotEmpty) {
    targetId = atRisk.first.id;
  } else if (delayed.isNotEmpty) {
    targetId = delayed.first.id;
  } else if (others.isNotEmpty) {
    targetId = others.first.id;
  } else {
    targetId = projects.first.id;
  }

  // 3. Fetch advisory for the chosen project
  return repository.fetchProjectAdvisory(targetId);
});
