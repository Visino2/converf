import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/project_image.dart';

final projectImageRepositoryProvider = Provider<ProjectImageRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProjectImageRepository(ApiClient(dio));
});

class ProjectImageRepository {
  final ApiClient _apiClient;

  ProjectImageRepository(this._apiClient);

  Future<ProjectImageListResponse> fetchImages(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/images');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectImageListResponse.fromJson(response.data);
  }

  Future<ProjectImage> uploadImage({
    required String projectId,
    required String filePath,
    String? caption,
    bool isPrimary = false,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
      if (caption != null) 'caption': caption,
      'is_primary': isPrimary,
    });

    debugPrint('Uploading image to: /api/v1/projects/$projectId/images');
    debugPrint('File path: $filePath');
    debugPrint('Form data: ${formData.fields}');

    try {
      final response = await _apiClient.post(
        '/api/v1/projects/$projectId/images',
        data: formData,
      );
      
      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response data: ${response.data}');
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }
      final data = response.data as Map<String, dynamic>;
      
      // Some APIs return data directly, others wrap it in a 'data' field
      final imageData = data['data'] ?? data;
      if (imageData is! Map<String, dynamic>) {
         throw Exception(data['message'] ?? 'Failed to upload image');
      }
      
      return ProjectImage.fromJson(imageData);

    } catch (e, st) {
      debugPrint('ProjectImageRepository: Error uploading image: $e');
      if (e is DioException) {
         final resData = e.response?.data;
         if (resData is Map<String, dynamic> && resData['message'] != null) {
            throw Exception(resData['message']);
         }
      }
      rethrow;
    }
  }

  Future<void> deleteImage(String projectId, String imageId) async {
    await _apiClient.delete('/api/v1/projects/$projectId/images/$imageId');
  }
}
