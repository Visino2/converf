import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_report_models.dart';
import '../repositories/daily_report_repository.dart';

final dailyReportsProvider = FutureProvider.family<DailyReportsResponse, ({String projectId, String? status})>((ref, args) async {
  final repository = ref.read(dailyReportRepositoryProvider);
  return repository.fetchDailyReports(args.projectId, filters: DailyReportFilters(status: args.status));
});

final dailyReportDetailProvider = FutureProvider.family<DailyReport, ({String projectId, String reportId})>((ref, args) async {
  if (args.projectId.isEmpty || args.reportId.isEmpty) throw Exception('Invalid arguments');
  final repository = ref.read(dailyReportRepositoryProvider);
  return repository.fetchDailyReport(args.projectId, args.reportId);
});

final dailyReportFormMetaProvider = FutureProvider.family<DailyReportFormMeta, ({String projectId, String date})>((ref, args) async {
  if (args.projectId.isEmpty || args.date.isEmpty) throw Exception('Invalid arguments');
  final repository = ref.read(dailyReportRepositoryProvider);
  return repository.fetchDailyReportFormMeta(args.projectId, args.date);
});

class DailyReportNotifier extends AsyncNotifier<void> {
  late DailyReportRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(dailyReportRepositoryProvider);
  }

  Future<Map<String, dynamic>> upsertDraft(String projectId, DailyReportDraftPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.upsertDailyReportDraft(projectId, payload);
      state = const AsyncData(null);
      
      // Invalidate queries to trigger a refresh
      ref.invalidate(dailyReportsProvider);
      
      final newReportId = response['data']?['id']?.toString();
      if (newReportId != null) {
        ref.invalidate(dailyReportDetailProvider((projectId: projectId, reportId: newReportId)));
      }
      
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSection(String projectId, String reportId, DailyReportSectionUpdatePayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.updateDailyReportSection(projectId, reportId, payload);
      state = const AsyncData(null);
      
      ref.invalidate(dailyReportsProvider);
      ref.invalidate(dailyReportDetailProvider((projectId: projectId, reportId: reportId)));
      
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitReport(String projectId, String reportId) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.submitDailyReport(projectId, reportId);
      state = const AsyncData(null);
      
      ref.invalidate(dailyReportsProvider);
      ref.invalidate(dailyReportDetailProvider((projectId: projectId, reportId: reportId)));
      
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<List<int>> exportPdf(String projectId, String reportId) async {
    state = const AsyncLoading();
    try {
      final bytes = await _repository.exportDailyReportPdf(projectId, reportId);
      state = const AsyncData(null);
      return bytes;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<List<int>> exportXlsx(String projectId, String reportId) async {
    state = const AsyncLoading();
    try {
      final bytes = await _repository.exportDailyReportXlsx(projectId, reportId);
      state = const AsyncData(null);
      return bytes;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final dailyReportActionProvider = AsyncNotifierProvider<DailyReportNotifier, void>(DailyReportNotifier.new);
