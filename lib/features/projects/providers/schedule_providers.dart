import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule.dart';
import '../models/schedule_library.dart';
import '../repositories/schedule_repository.dart';
import '../repositories/schedule_library_repository.dart';



final projectScheduleProvider = FutureProvider.family<Schedule, String>((ref, projectId) async {
  final repo = ref.read(scheduleRepositoryProvider);
  return repo.getProjectScheduleDetail(projectId);
});

final schedulePhasesProvider = FutureProvider.family<List<SchedulePhase>, String>((ref, scheduleId) async {
  final repo = ref.read(scheduleRepositoryProvider);
  return repo.getPhases(scheduleId);
});

final scheduleLibraryPhasesProvider = FutureProvider<List<TemplatePhase>>((ref) async {
  final repo = ref.read(scheduleLibraryRepositoryProvider);
  return repo.getTemplatePhases();
});

final scheduleLibraryActivitiesProvider = FutureProvider.family<List<TemplateActivity>, String>((ref, phaseId) async {
  final repo = ref.read(scheduleLibraryRepositoryProvider);
  return repo.getTemplatePhaseActivities(phaseId);
});

final scheduleLibraryMilestonesProvider = FutureProvider<List<TemplateMilestone>>((ref) async {
  final repo = ref.read(scheduleLibraryRepositoryProvider);
  return repo.getMilestones();
});

// --- ACTION NOTIFIER ---

class ScheduleNotifier extends AsyncNotifier<void> {
  late ScheduleRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(scheduleRepositoryProvider);
  }

  Future<void> createScheduleFromBid(String bidId, String contractorNotes) async {
    state = const AsyncLoading();
    try {
      await _repository.createScheduleFromBid(bidId, contractorNotes);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> createScheduleFromProject(String projectId, String contractorNotes) async {
    state = const AsyncLoading();
    try {
      await _repository.createScheduleFromProject(projectId, contractorNotes);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> createActivity(String scheduleId, String phaseId, String projectId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repository.createActivity(scheduleId, phaseId, data);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateActivity(String scheduleId, String phaseId, String activityId, String projectId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repository.updateActivity(scheduleId, phaseId, activityId, data);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteActivity(String scheduleId, String phaseId, String activityId, String projectId) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteActivity(scheduleId, phaseId, activityId);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> createPhase(String scheduleId, String projectId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repository.createPhase(scheduleId, data);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updatePhase(String scheduleId, String phaseId, String projectId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repository.updatePhase(scheduleId, phaseId, data);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deletePhase(String scheduleId, String phaseId, String projectId) async {
    state = const AsyncLoading();
    try {
      await _repository.deletePhase(scheduleId, phaseId);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> importTemplates(String scheduleId, String projectId, List<ScheduleImportSelection> selections) async {
    state = const AsyncLoading();
    try {
      await _repository.importTemplates(scheduleId, selections);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> submitSchedule(String scheduleId, String projectId, String contractorNotes) async {
    state = const AsyncLoading();
    try {
      await _repository.submitSchedule(scheduleId, contractorNotes);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> approveSchedule(String scheduleId, String projectId) async {
    state = const AsyncLoading();
    try {
      await _repository.approveSchedule(scheduleId);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> requestRevision(String scheduleId, String projectId, String feedback) async {
    state = const AsyncLoading();
    try {
      await _repository.requestRevision(scheduleId, feedback);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> rejectSchedule(String scheduleId, String projectId, String feedback) async {
    state = const AsyncLoading();
    try {
      await _repository.rejectSchedule(scheduleId, feedback);
      state = const AsyncData(null);
      ref.invalidate(projectScheduleProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final scheduleActionProvider = AsyncNotifierProvider<ScheduleNotifier, void>(ScheduleNotifier.new);
