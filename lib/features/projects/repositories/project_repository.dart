import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dio_provider.dart';
import '../../../core/api/api_client.dart';
import '../models/project_payloads.dart';
import '../models/project_responses.dart';
import '../models/project.dart';
import '../models/project_advisory.dart';
import '../models/project_responsibility.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProjectRepository(ApiClient(dio));
});

class ProjectRepository {
  final ApiClient _apiClient;

  ProjectRepository(this._apiClient);

  Future<PaginatedProjectsResponse> fetchProjects({int page = 1}) async {
    final response = await _apiClient.get(
      '/api/v1/projects',
      queryParameters: {'page': page},
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return PaginatedProjectsResponse.fromJson(response.data);
  }

  Future<ProjectResponse> fetchProjectById(String projectId) async {
    debugPrint('--- ProjectRepository: fetchProjectById($projectId) ---');
    try {
      final response = await _apiClient.get('/api/v1/projects/$projectId');
      debugPrint(
        '--- ProjectRepository: Received response: ${response.statusCode} ---',
      );
      debugPrint('--- Full response data: ${response.data} ---');

      if (response.data is! Map<String, dynamic>) {
        debugPrint('--- ProjectRepository ERROR: Invalid response format ---');
        throw Exception("Invalid response format from server");
      }

      final result = ProjectResponse.fromJson(response.data);
      debugPrint(
        '--- ProjectRepository: Parsing successful. Project: ${result.data?.title} ---',
      );
      debugPrint(
        '--- ProjectRepository: Cover images count: ${result.data?.coverImages.length} ---',
      );
      return result;
    } catch (e, stack) {
      debugPrint('--- ProjectRepository ERROR: $e ---');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  Future<ProjectFinancials> fetchProjectFinancials(String projectId) async {
    final response = await _apiClient.get(
      '/api/v1/projects/$projectId/financials',
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }

    final data = response.data;
    if (data.containsKey('data')) {
      return ProjectFinancials.fromJson(data['data'] as Map<String, dynamic>);
    }
    return ProjectFinancials.fromJson(data);
  }

  Future<WizardResponse> startWizard(StartWizardPayload payload) async {
    debugPrint('--- [REQ] POST /api/v1/projects/wizard ---');
    debugPrint('Payload: ${payload.toJson()}');
    final response = await _apiClient.post(
      '/api/v1/projects/wizard',
      data: payload.toJson(),
    );
    debugPrint('--- [RES] 200 OK ---');
    debugPrint('Body: ${response.data}');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> updateBasicInfo(
    String projectId,
    UpdateBasicInfoPayload payload,
  ) async {
    debugPrint('--- [REQ] PATCH /api/v1/projects/wizard/$projectId ---');
    debugPrint('Payload: ${payload.toJson()}');
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    debugPrint('--- [RES] 200 OK ---');
    debugPrint('Body: ${response.data}');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> updateLocation(
    String projectId,
    UpdateLocationPayload payload,
  ) async {
    debugPrint(
      '--- [REQ] PATCH /api/v1/projects/wizard/$projectId (Location) ---',
    );
    debugPrint('Payload: ${payload.toJson()}');
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    debugPrint('--- [RES] 200 OK ---');
    debugPrint('Body: ${response.data}');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> updateTimelineBudget(
    String projectId,
    UpdateTimelineBudgetPayload payload,
  ) async {
    debugPrint(
      '--- [REQ] PATCH /api/v1/projects/wizard/$projectId (Timeline) ---',
    );
    debugPrint('Payload: ${payload.toJson()}');
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    debugPrint('--- [RES] 200 OK ---');
    debugPrint('Body: ${response.data}');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> updateSpecialisations(
    String projectId,
    UpdateSpecialisationsPayload payload,
  ) async {
    debugPrint(
      '--- [REQ] PATCH /api/v1/projects/wizard/$projectId (Specs) ---',
    );
    debugPrint('Payload: ${payload.toJson()}');
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    debugPrint('--- [RES] 200 OK ---');
    debugPrint('Body: ${response.data}');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> confirmProject(
    String projectId,
    ConfirmProjectPayload payload,
  ) async {
    debugPrint(
      '--- [REQ] PATCH /api/v1/projects/wizard/$projectId (Confirm) ---',
    );
    debugPrint('Payload: ${payload.toJson()}');
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    debugPrint('--- [RES] 200 OK ---');
    debugPrint('Body: ${response.data}');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> finalAssignContractor(
    String projectId,
    FinalAssignPayload payload,
  ) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<PaginatedProjectsResponse> fetchAssignedProjects({
    int page = 1,
  }) async {
    debugPrint('[ProjectRepo] Calling /api/v1/projects (assigned)...');
    try {
      final response = await _apiClient.get(
        '/api/v1/projects',
        queryParameters: {'page': page},
      );
      debugPrint('[ProjectRepo] Response received: ${response.statusCode}');
      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }
      final result = PaginatedProjectsResponse.fromJson(response.data);
      debugPrint(
        '[ProjectRepo] Parsing successful. Projects found: ${result.data.length}',
      );
      return result;
    } catch (e) {
      debugPrint('[ProjectRepo] Error in fetchAssignedProjects: $e');
      rethrow;
    }
  }

  Future<ProjectResponse> uploadProjectThumbnail(
    String projectId,
    String filePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'thumbnail': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      // Use /thumbnail endpoint for cover images (doesn't require GPS coordinates)
      final response = await _apiClient.post(
        '/api/v1/projects/$projectId/thumbnail',
        data: formData,
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }
      debugPrint(
        '[ProjectRepo] uploadThumbnail raw response: ${response.data}',
      );
      return ProjectResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[ProjectRepo] DioException uploading thumbnail: $e');
      final resData = e.response?.data;
      if (resData is Map<String, dynamic> && resData['message'] != null) {
        throw Exception(resData['message']);
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('Connection timeout. Please check your internet.');
        case DioExceptionType.receiveTimeout:
          throw Exception('Server took too long to respond. Please try again.');
        case DioExceptionType.unknown:
          if (e.message?.contains('SocketException') ?? false) {
            throw Exception('No internet connection.');
          }
          throw Exception(e.message ?? 'Failed to upload thumbnail.');
        default:
          throw Exception(e.message ?? 'Failed to upload thumbnail.');
      }
    } catch (e) {
      debugPrint('[ProjectRepo] Error uploading thumbnail: $e');
      rethrow;
    }
  }

  Future<ProjectResponse> deleteProjectThumbnail(
    String projectId,
    String coverImageId,
  ) async {
    try {
      // Use /thumbnail endpoint to match upload and correctly handle the 3-image limit
      final response = await _apiClient.delete(
        '/api/v1/projects/$projectId/thumbnail/$coverImageId',
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
      }
      return ProjectResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[ProjectRepo] DioException deleting thumbnail: $e');
      final resData = e.response?.data;
      if (resData is Map<String, dynamic> && resData['message'] != null) {
        throw Exception(resData['message']);
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Image not found or already deleted.');
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('Connection timeout. Please check your internet.');
        case DioExceptionType.receiveTimeout:
          throw Exception('Server took too long to respond. Please try again.');
        case DioExceptionType.unknown:
          if (e.message?.contains('SocketException') ?? false) {
            throw Exception('No internet connection.');
          }
          throw Exception(e.message ?? 'Failed to delete image.');
        default:
          throw Exception(e.message ?? 'Failed to delete image.');
      }
    } catch (e) {
      debugPrint('[ProjectRepo] Error deleting thumbnail: $e');
      rethrow;
    }
  }

  Future<ProjectResponse> updateSiteCoordinates(
    String projectId, {
    required double latitude,
    required double longitude,
    required int geofenceRadiusM,
  }) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/$projectId/site-coordinates',
      data: {
        'site_latitude': latitude,
        'site_longitude': longitude,
        'site_geofence_radius_m': geofenceRadiusM,
      },
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectResponse.fromJson(response.data);
  }

  Future<void> updateProjectAssignment(
    String projectId, {
    required String assignmentMethod,
    String? contractorId,
    String? biddingDeadline,
  }) async {
    final payload = <String, dynamic>{
      'assignment_method': assignmentMethod,
      if (contractorId?.isNotEmpty ?? false) 'contractor_id': contractorId,
      if (biddingDeadline?.isNotEmpty ?? false) 'bidding_deadline': biddingDeadline,
    };
    debugPrint('[UpdateAssignment] PATCH /api/v1/projects/wizard/$projectId');
    debugPrint('[UpdateAssignment] Payload: $payload');
    try {
      final response = await _apiClient.patch(
        '/api/v1/projects/wizard/$projectId',
        data: payload,
      );
      debugPrint('[UpdateAssignment] ✅ Success: ${response.statusCode} ${response.data}');
    } catch (e, st) {
      debugPrint('[UpdateAssignment] ❌ Error: $e');
      debugPrint('[UpdateAssignment] Stack: $st');
      rethrow;
    }
  }

  Future<ProjectAdvisoryResponse> fetchProjectAdvisory(String projectId) async {
    final response = await _apiClient.get(
      '/api/v1/projects/$projectId/advisory',
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectAdvisoryResponse.fromJson(response.data);
  }

  Future<ProjectAdvisoryResponse> fetchProjectHealthScore(
    String projectId,
  ) async {
    final response = await _apiClient.get(
      '/api/v1/projects/$projectId/health-score',
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectAdvisoryResponse.fromJson(response.data);
  }

  Future<ProjectResponsibilityResponse> fetchProjectResponsibility(
    String projectId,
  ) async {
    final response = await _apiClient.get(
      '/api/v1/projects/$projectId/responsibility',
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ProjectResponsibilityResponse.fromJson(response.data);
  }

  Future<void> addContractorParticipant(
    String projectId,
    String contractorId,
  ) async {
    debugPrint('--- [REQ] POST /api/v1/projects/$projectId/participants ---');
    debugPrint('Payload: {contractor_id: $contractorId}');
    try {
      await _apiClient.post(
        '/api/v1/projects/$projectId/participants',
        data: {'contractor_id': contractorId},
      );
      debugPrint('--- [RES] 200 OK - Contractor participant added ---');
    } catch (e) {
      debugPrint('--- [ERROR] Failed to add contractor participant: $e ---');
      rethrow;
    }
  }
}
