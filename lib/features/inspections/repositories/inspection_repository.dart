import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/dio_provider.dart';
import '../models/inspection_models.dart';

class InspectionRepository {
  final ApiClient _apiClient;

  InspectionRepository(this._apiClient);

  Future<InspectionsResponse> fetchFieldInspections(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/inspections');
    return InspectionsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> createFieldInspection(String projectId, CreateInspectionPayload payload) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('inspection_date', payload.inspectionDate),
      MapEntry('summary', payload.summary),
    ]);

    if (payload.findings != null) {
      formData.fields.add(MapEntry('findings', payload.findings!));
    }

    if (payload.status != null) {
      formData.fields.add(MapEntry('status', payload.status!));
    }

    if (payload.locationCoordinates != null) {
      formData.fields.add(MapEntry('location_coordinates', payload.locationCoordinates!));
    }

    if (payload.phase != null) {
      formData.fields.add(MapEntry('phase', payload.phase!));
    }

    for (final imagePath in payload.images) {
      final file = await MultipartFile.fromFile(imagePath);
      formData.files.add(MapEntry('images[]', file));
    }

    // Use raw dio.post to pass the FormData object natively, and specify the content type.
    final response = await _apiClient.dio.post(
      '/api/v1/projects/$projectId/inspections',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return response.data as Map<String, dynamic>;
  }
}

final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InspectionRepository(ApiClient(dio));
});
