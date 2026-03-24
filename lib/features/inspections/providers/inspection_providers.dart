import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inspection_models.dart';
import '../repositories/inspection_repository.dart';

final inspectionsProvider = FutureProvider.family<InspectionsResponse, String>((ref, projectId) async {
  if (projectId.isEmpty) return InspectionsResponse(status: false, message: 'Invalid ID', data: []);
  final repository = ref.read(inspectionRepositoryProvider);
  return repository.fetchFieldInspections(projectId);
});

class InspectionNotifier extends AsyncNotifier<void> {
  late InspectionRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(inspectionRepositoryProvider);
  }

  Future<Map<String, dynamic>> createInspection(String projectId, CreateInspectionPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.createFieldInspection(projectId, payload);
      state = const AsyncData(null);
      
      // Invalidate the list query to trigger a refresh
      ref.invalidate(inspectionsProvider(projectId));
      
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final inspectionActionProvider = AsyncNotifierProvider<InspectionNotifier, void>(InspectionNotifier.new);
