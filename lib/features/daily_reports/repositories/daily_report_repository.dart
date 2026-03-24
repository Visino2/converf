import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/dio_provider.dart';
import '../models/daily_report_models.dart';

class DailyReportRepository {
  final ApiClient _apiClient;

  DailyReportRepository(this._apiClient);

  Future<DailyReportsResponse> fetchDailyReports(String projectId, {DailyReportFilters? filters}) async {
    final response = await _apiClient.get(
      '/api/v1/projects/$projectId/daily-reports',
      queryParameters: filters?.toJson(),
    );
    return DailyReportsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DailyReport> fetchDailyReport(String projectId, String reportId) async {
    final response = await _apiClient.get(
      '/api/v1/projects/$projectId/daily-reports/$reportId',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return DailyReport.fromJson(data);
  }

  Future<DailyReportFormMeta> fetchDailyReportFormMeta(String projectId, String date) async {
    final response = await _apiClient.get(
      '/api/v1/projects/$projectId/daily-reports/form-meta',
      queryParameters: {'date': date},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return DailyReportFormMeta.fromJson(data);
  }

  Future<Map<String, dynamic>> upsertDailyReportDraft(String projectId, DailyReportDraftPayload payload) async {
    final response = await _apiClient.post(
      '/api/v1/projects/$projectId/daily-reports/drafts',
      data: payload.toJson(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateDailyReportSection(
    String projectId,
    String reportId,
    DailyReportSectionUpdatePayload payload,
  ) async {
    final response = await _apiClient.patch(
      '/api/v1/projects/$projectId/daily-reports/$reportId',
      data: payload.toJson(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitDailyReport(String projectId, String reportId) async {
    final response = await _apiClient.post(
      '/api/v1/projects/$projectId/daily-reports/$reportId/submit',
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<int>> exportDailyReportPdf(String projectId, String reportId) async {
    final response = await _apiClient.dio.get<List<int>>(
      '/api/v1/projects/$projectId/daily-reports/$reportId/export.pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }

  Future<List<int>> exportDailyReportXlsx(String projectId, String reportId) async {
    final response = await _apiClient.dio.get<List<int>>(
      '/api/v1/projects/$projectId/daily-reports/$reportId/export.xlsx',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}


final dailyReportRepositoryProvider = Provider<DailyReportRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DailyReportRepository(ApiClient(dio));
});
