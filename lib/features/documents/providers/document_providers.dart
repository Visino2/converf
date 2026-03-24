import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../models/document_models.dart';
import '../repositories/document_repository.dart';

final documentsProvider = FutureProvider.family<DocumentsResponse, String>((ref, projectId) async {
  if (projectId.isEmpty) return DocumentsResponse(status: false, message: 'Invalid ID', data: []);
  final repository = ref.read(documentRepositoryProvider);
  return repository.fetchDocuments(projectId);
});

class DocumentNotifier extends AsyncNotifier<void> {
  late DocumentRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(documentRepositoryProvider);
  }

  Future<Map<String, dynamic>> uploadDocument(String projectId, UploadDocumentPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.uploadDocument(projectId, payload);
      state = const AsyncData(null);
      
      // Refresh the list of documents
      ref.invalidate(documentsProvider(projectId));
      return response;
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
      
      ref.invalidate(documentsProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> downloadAndOpenDocument(String projectId, ProjectDocument document) async {
    state = const AsyncLoading();
    try {
      final bytes = await _repository.downloadDocument(projectId, document.id);
      
      // Save it temporarily so we can open it natively
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${document.name}');
      await file.writeAsBytes(bytes);
      
      // Open the file with the native viewer
      await OpenFilex.open(file.path);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final documentActionProvider = AsyncNotifierProvider<DocumentNotifier, void>(DocumentNotifier.new);
