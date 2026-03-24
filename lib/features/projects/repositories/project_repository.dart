import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dio_provider.dart';
import '../../../core/api/api_client.dart';
import '../models/project_payloads.dart';
import '../models/project_responses.dart';
import '../models/project.dart';

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
      debugPrint('--- ProjectRepository: Received response: ${response.statusCode} ---');
      
      if (response.data is! Map<String, dynamic>) {
        debugPrint('--- ProjectRepository ERROR: Invalid response format ---');
        throw Exception("Invalid response format from server");
      }
      
      final result = ProjectResponse.fromJson(response.data);
      debugPrint('--- ProjectRepository: Parsing successful. Project: ${result.data?.title} ---');
      return result;
    } catch (e, stack) {
      debugPrint('--- ProjectRepository ERROR: $e ---');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  Future<ProjectFinancials> fetchProjectFinancials(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/financials'); 
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
    final response = await _apiClient.post(
      '/api/v1/projects/wizard',
      data: payload.toJson(),
    );
    debugPrint('*** Wizard Response ***');
    debugPrint(response.data.toString());
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> updateBasicInfo(String projectId, UpdateBasicInfoPayload payload) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> updateLocation(String projectId, UpdateLocationPayload payload) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> updateTimelineBudget(String projectId, UpdateTimelineBudgetPayload payload) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> updateSpecialisations(String projectId, UpdateSpecialisationsPayload payload) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> confirmProject(String projectId, ConfirmProjectPayload payload) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<WizardResponse> finalAssignContractor(String projectId, FinalAssignPayload payload) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/wizard/$projectId',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return WizardResponse.fromJson(response.data);
  }

  Future<PaginatedProjectsResponse> fetchAssignedProjects({int page = 1}) async {
    final response = await _apiClient.get(
      '/api/v1/projects',
      queryParameters: {'page': page},
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return PaginatedProjectsResponse.fromJson(response.data);
  }
}
