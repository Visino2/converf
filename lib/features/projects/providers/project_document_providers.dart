import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/project_document.dart';
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

  Future<void> downloadAndOpenDocument(String projectId, ProjectDocument document) async {
    state = const AsyncLoading();
    try {
      final tempDir = await getTemporaryDirectory();
      // Ensure the filename is safe and has the right extension if possible
      final fileName = document.name.replaceAll(RegExp(r'[^\w\s\.-]'), '_');
      final savePath = '${tempDir.path}/$fileName';
      
      await _repository.downloadDocument(projectId, document.id, savePath);
      
      await OpenFilex.open(savePath);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final projectDocumentNotifierProvider = AsyncNotifierProvider<ProjectDocumentNotifier, void>(ProjectDocumentNotifier.new);
