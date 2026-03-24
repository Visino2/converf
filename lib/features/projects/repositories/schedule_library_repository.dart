import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/schedule_library.dart';

final scheduleLibraryRepositoryProvider = Provider<ScheduleLibraryRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ScheduleLibraryRepository(ApiClient(dio));
});

class ScheduleLibraryRepository {
  final ApiClient _apiClient;

  ScheduleLibraryRepository(this._apiClient);

  Future<List<TemplatePhase>> getTemplatePhases() async {
    final response = await _apiClient.get('/api/v1/schedule-library/phases');
    if (response.data is! Map<String, dynamic>) {
       throw Exception("Invalid response format from server");
    }
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => TemplatePhase.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TemplatePhase> getTemplatePhase(String phaseId) async {
    final response = await _apiClient.get('/api/v1/schedule-library/phases/$phaseId');
    if (response.data is! Map<String, dynamic>) {
       throw Exception("Invalid response format from server");
    }
    final data = response.data['data'] ?? response.data;
    return TemplatePhase.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TemplateActivity>> getTemplatePhaseActivities(String phaseId) async {
    final response = await _apiClient.get('/api/v1/schedule-library/phases/$phaseId/activities');
    if (response.data is! Map<String, dynamic>) {
       throw Exception("Invalid response format from server");
    }
    final data = response.data['data'];
    if (data is Map<String, dynamic> && data['activities'] is List) {
      final List activities = data['activities'];
      return activities.map((e) => TemplateActivity.fromJson(e as Map<String, dynamic>)).toList();
    }
    // Fallback if data is a direct list
    if (data is List) {
       return data.map((e) => TemplateActivity.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<TemplateActivity>> getTemplateActivities({
    String? phaseId,
    bool? isMilestone,
    bool? canRunParallel,
    String? search,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (perPage != null) queryParameters['per_page'] = perPage;
    if (phaseId != null) queryParameters['phase_id'] = phaseId;
    if (isMilestone != null) queryParameters['is_milestone'] = isMilestone;
    if (canRunParallel != null) queryParameters['can_run_parallel'] = canRunParallel;
    if (search != null) queryParameters['search'] = search;

    final response = await _apiClient.get(
      '/api/v1/schedule-library/activities',
      queryParameters: queryParameters,
    );
    if (response.data is! Map<String, dynamic>) {
       throw Exception("Invalid response format from server");
    }
    final data = response.data['data'];
    if (data is List) {
      return data.map((e) => TemplateActivity.fromJson(e as Map<String, dynamic>)).toList();
    } else if (data is Map && data['data'] is List) {
      // Handles paginated response where data is inside a 'data' field of the wrapper
      return (data['data'] as List).map((e) => TemplateActivity.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<TemplateActivity> getTemplateActivityByCode(String code) async {
    final response = await _apiClient.get('/api/v1/schedule-library/activities/$code');
    if (response.data is! Map<String, dynamic>) {
       throw Exception("Invalid response format from server");
    }
    final data = response.data['data'] ?? response.data;
    return TemplateActivity.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TemplateMilestone>> getMilestones() async {
    final response = await _apiClient.get('/api/v1/schedule-library/milestones');
    if (response.data is! Map<String, dynamic>) {
       throw Exception("Invalid response format from server");
    }
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => TemplateMilestone.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ParallelGroup>> getParallelGroups() async {
    final response = await _apiClient.get('/api/v1/schedule-library/parallel-groups');
    if (response.data is! Map<String, dynamic>) {
       throw Exception("Invalid response format from server");
    }
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => ParallelGroup.fromJson(e as Map<String, dynamic>)).toList();
  }
}
