import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/dio_provider.dart';
import '../models/document_models.dart';

class DocumentRepository {
  final ApiClient _apiClient;

  DocumentRepository(this._apiClient);

  Future<DocumentsResponse> fetchDocuments(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/documents');
    return DocumentsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> uploadDocument(String projectId, UploadDocumentPayload payload) async {
    final formData = FormData();
    formData.fields.add(MapEntry('type', payload.type));
    
    if (payload.name != null && payload.name!.isNotEmpty) {
      formData.fields.add(MapEntry('name', payload.name!));
    }

    final file = await MultipartFile.fromFile(payload.filePath);
    formData.files.add(MapEntry('file', file));

    final response = await _apiClient.dio.post(
      '/api/v1/projects/$projectId/documents',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteDocument(String projectId, String documentId) async {
    final response = await _apiClient.delete('/api/v1/projects/$projectId/documents/$documentId');
    return response.data as Map<String, dynamic>? ?? {};
  }

  Future<List<int>> downloadDocument(String projectId, String documentId) async {
    final response = await _apiClient.dio.get<List<int>>(
      '/api/v1/projects/$projectId/documents/$documentId/download',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DocumentRepository(ApiClient(dio));
});
