import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_document.dart';
import '../models/project_document_responses.dart';
import '../repositories/project_document_repository.dart';

final projectDocumentsProvider = FutureProvider.family<List<ProjectDocument>, String>((ref, projectId) async {
  final repository = ref.read(projectDocumentRepositoryProvider);
  final response = await repository.fetchDocuments(projectId);
  return response.data;
});

final projectDocumentDetailsProvider = FutureProvider.family<ProjectDocument, (String, String)>((ref, ids) async {
  final projectId = ids.$1;
  final documentId = ids.$2;
  final repository = ref.read(projectDocumentRepositoryProvider);
  final response = await repository.fetchDocumentById(projectId, documentId);
  return response.data;
});

class ProjectDocumentNotifier extends AsyncNotifier<void> {
  late ProjectDocumentRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(projectDocumentRepositoryProvider);
  }

  Future<void> uploadDocument({
    required String projectId,
    required String filePath,
    required String name,
    required String type,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.uploadDocument(
        projectId: projectId,
        filePath: filePath,
        name: name,
        type: type,
      );
      state = const AsyncData(null);
      ref.invalidate(projectDocumentsProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteDocument(String projectId, String documentId) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteDocument(projectId, documentId);
      state = const AsyncData(null);
      ref.invalidate(projectDocumentsProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> downloadDocument(String projectId, String documentId, String savePath) async {
    state = const AsyncLoading();
    try {
      await _repository.downloadDocument(projectId, documentId, savePath);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final projectDocumentNotifierProvider = AsyncNotifierProvider<ProjectDocumentNotifier, void>(ProjectDocumentNotifier.new);
