import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/project_document_responses.dart';

final projectDocumentRepositoryProvider = Provider<ProjectDocumentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProjectDocumentRepository(ApiClient(dio));
});

class ProjectDocumentRepository {
  final ApiClient _apiClient;

  ProjectDocumentRepository(this._apiClient);

  Future<ProjectDocumentListResponse> fetchDocuments(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/documents');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectDocumentListResponse.fromJson(response.data);
  }

  Future<ProjectDocumentResponse> uploadDocument({
    required String projectId,
    required String filePath,
    required String name,
    required String type,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: name),
      'name': name,
      'type': type,
    });

    final response = await _apiClient.post(
      '/api/v1/projects/$projectId/documents',
      data: formData,
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectDocumentResponse.fromJson(response.data);
  }

  Future<ProjectDocumentResponse> fetchDocumentById(String projectId, String documentId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/documents/$documentId');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectDocumentResponse.fromJson(response.data);
  }

  Future<void> deleteDocument(String projectId, String documentId) async {
    await _apiClient.delete('/api/v1/projects/$projectId/documents/$documentId');
  }

  Future<String> getDownloadUrl(String projectId, String documentId) async {
    // According to the requirement: GET /api/v1/projects/{project}/documents/{document}/download
    // returns a file download stream. For Flutter, we might just need the full URL if it's public,
    // or use Dio to download it. For now, I'll return the constructed URL or implement a download method.
    return '${_apiClient.dio.options.baseUrl}/api/v1/projects/$projectId/documents/$documentId/download';
  }
  
  Future<void> downloadDocument(String projectId, String documentId, String savePath) async {
    await _apiClient.dio.download(
      '/api/v1/projects/$projectId/documents/$documentId/download',
      savePath,
    );
  }
}
