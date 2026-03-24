import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/phase_models.dart';
import '../repositories/phase_repository.dart';

final phasesProvider = FutureProvider.family<PhasesResponse, String>((ref, projectId) async {
  if (projectId.isEmpty) return PhasesResponse(status: false, message: 'Invalid ID', data: []);
  final repository = ref.read(phaseRepositoryProvider);
  return repository.fetchPhases(projectId);
});
