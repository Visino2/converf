import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milestone_models.dart';
import '../repositories/milestone_repository.dart';

final milestonesProvider = FutureProvider.family<MilestonesResponse, String>((ref, projectId) async {
  if (projectId.isEmpty) return MilestonesResponse(status: false, message: 'Invalid ID', data: []);
  final repository = ref.read(milestoneRepositoryProvider);
  return repository.fetchMilestones(projectId);
});
