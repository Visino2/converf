import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/schedule.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ScheduleRepository(ApiClient(dio));
});

class ScheduleRepository {
  final ApiClient _apiClient;

  ScheduleRepository(this._apiClient);

  // --- ACTIVITIES ---

  Future<List<ScheduleActivity>> getActivities(String scheduleId, String phaseId) async {
    final response = await _apiClient.get('/api/v1/schedules/$scheduleId/phases/$phaseId/activities');
    if (response.data is List) {
      return (response.data as List).map((e) => ScheduleActivity.fromJson(e)).toList();
    } else if (response.data is Map && response.data['data'] is List) {
      return (response.data['data'] as List).map((e) => ScheduleActivity.fromJson(e)).toList();
    }
    throw Exception("Invalid response format from server");
  }

  Future<ScheduleActivity> createActivity(String scheduleId, String phaseId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '/api/v1/schedules/$scheduleId/phases/$phaseId/activities',
      data: data,
    );
    if (response.data is Map<String, dynamic>) {
      // Sometimes APIs return the object directly or nested in 'data'
      final map = response.data['data'] ?? response.data;
      return ScheduleActivity.fromJson(map);
    }
    throw Exception("Invalid response format from server");
  }

  Future<void> updateActivity(String scheduleId, String phaseId, String activityId, Map<String, dynamic> data) async {
    await _apiClient.patch(
      '/api/v1/schedules/$scheduleId/phases/$phaseId/activities/$activityId',
      data: data,
    );
  }

  Future<void> deleteActivity(String scheduleId, String phaseId, String activityId) async {
    await _apiClient.delete('/api/v1/schedules/$scheduleId/phases/$phaseId/activities/$activityId');
  }

  // --- PHASES ---

  Future<List<SchedulePhase>> getPhases(String scheduleId) async {
    final response = await _apiClient.get('/api/v1/schedules/$scheduleId/phases');
    if (response.data is List) {
      return (response.data as List).map((e) => SchedulePhase.fromJson(e)).toList();
    } else if (response.data is Map && response.data['data'] is List) {
      return (response.data['data'] as List).map((e) => SchedulePhase.fromJson(e)).toList();
    }
    throw Exception("Invalid response format from server");
  }

  Future<SchedulePhase> createPhase(String scheduleId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '/api/v1/schedules/$scheduleId/phases',
      data: data,
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data['data'] ?? response.data;
      return SchedulePhase.fromJson(map);
    }
    throw Exception("Invalid response format from server");
  }

  Future<void> updatePhase(String scheduleId, String phaseId, Map<String, dynamic> data) async {
    await _apiClient.patch(
      '/api/v1/schedules/$scheduleId/phases/$phaseId',
      data: data,
    );
  }

  Future<void> deletePhase(String scheduleId, String phaseId) async {
    await _apiClient.delete('/api/v1/schedules/$scheduleId/phases/$phaseId');
  }

  // --- SCHEDULE CREATION & VIEWING ---

  Future<Schedule> createScheduleFromBid(String bidId, String contractorNotes) async {
    final response = await _apiClient.post(
      '/api/v1/bids/$bidId/schedule',
      data: {
        'contractor_notes': contractorNotes,
      },
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data['data'] ?? response.data;
      return Schedule.fromJson(map);
    }
    throw Exception("Invalid response format from server");
  }

  Future<void> submitScheduleFromBid(String bidId, String contractorNotes) async {
    await _apiClient.post(
      '/api/v1/bids/$bidId/schedule/submit',
      data: {'contractor_notes': contractorNotes},
    );
  }

  Future<Schedule> createScheduleFromProject(String projectId, String contractorNotes) async {
    final response = await _apiClient.post(
      '/api/v1/projects/$projectId/schedule',
      data: {
        'contractor_notes': contractorNotes,
      },
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data['data'] ?? response.data;
      return Schedule.fromJson(map);
    }
    throw Exception("Invalid response format from server");
  }

  Future<Schedule> getSchedule(String scheduleId) async {
    final response = await _apiClient.get('/api/v1/schedules/$scheduleId');
    if (response.data is Map<String, dynamic>) {
      final map = response.data['data'] ?? response.data;
      return Schedule.fromJson(map);
    }
    throw Exception("Invalid response format from server");
  }

  Future<Schedule> getProjectScheduleDetail(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/schedule');
    if (response.data is Map<String, dynamic>) {
      final map = response.data['data'] ?? response.data;
      return Schedule.fromJson(map);
    }
    throw Exception("Invalid response format from server");
  }

  Future<Schedule> getBidScheduleDetail(String bidId) async {
    final response = await _apiClient.get('/api/v1/bids/$bidId/schedule');
    if (response.data is Map<String, dynamic>) {
      final map = response.data['data'] ?? response.data;
      return Schedule.fromJson(map);
    }
    throw Exception("Invalid response format from server");
  }

  // --- SCHEDULE ACTIONS ---

  Future<void> importTemplates(String scheduleId, List<ScheduleImportSelection> selections) async {
    await _apiClient.post(
      '/api/v1/schedules/$scheduleId/import',
      data: {
        'selections': selections.map((s) => s.toJson()).toList(),
      },
    );
  }

  Future<void> submitSchedule(String scheduleId, String contractorNotes) async {
    await _apiClient.post(
      '/api/v1/schedules/$scheduleId/submit',
      data: {'contractor_notes': contractorNotes},
    );
  }

  Future<void> approveSchedule(String scheduleId) async {
    await _apiClient.patch('/api/v1/schedules/$scheduleId/approve', data: {});
  }

  Future<void> requestRevision(String scheduleId, String ownerFeedback) async {
    await _apiClient.patch(
      '/api/v1/schedules/$scheduleId/request-revision',
      data: {'owner_feedback': ownerFeedback},
    );
  }

  Future<void> rejectSchedule(String scheduleId, String ownerFeedback) async {
    await _apiClient.patch(
      '/api/v1/schedules/$scheduleId/reject',
      data: {'owner_feedback': ownerFeedback},
    );
  }
}
