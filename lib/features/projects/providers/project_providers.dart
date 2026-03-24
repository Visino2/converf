import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../models/project_payloads.dart';
import '../models/project_responses.dart';
import '../repositories/project_repository.dart';



final projectsListProvider = FutureProvider.family<PaginatedProjectsResponse, int>((ref, page) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.fetchProjects(page: page);
});

final assignedProjectsProvider = FutureProvider.family<PaginatedProjectsResponse, int>((ref, page) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.fetchAssignedProjects(page: page);
});

final projectDetailsProvider = FutureProvider.family<ProjectResponse, String>((ref, id) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.fetchProjectById(id);
});

final projectFinancialsProvider = FutureProvider.family<ProjectFinancials, String>((ref, id) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.fetchProjectFinancials(id);
});



class ProjectWizardNotifier extends AsyncNotifier<void> {
  late ProjectRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(projectRepositoryProvider);
  }

  Future<WizardResponse> startWizard(StartWizardPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.startWizard(payload);
      state = const AsyncData(null);
      
      ref.invalidate(projectsListProvider);
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<WizardResponse> updateBasicInfo(String projectId, UpdateBasicInfoPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.updateBasicInfo(projectId, payload);
      state = const AsyncData(null);
      ref.invalidate(projectDetailsProvider(projectId));
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<WizardResponse> updateLocation(String projectId, UpdateLocationPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.updateLocation(projectId, payload);
      state = const AsyncData(null);
      ref.invalidate(projectDetailsProvider(projectId));
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<WizardResponse> updateTimelineBudget(String projectId, UpdateTimelineBudgetPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.updateTimelineBudget(projectId, payload);
      state = const AsyncData(null);
      ref.invalidate(projectDetailsProvider(projectId));
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<WizardResponse> updateSpecialisations(String projectId, UpdateSpecialisationsPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.updateSpecialisations(projectId, payload);
      state = const AsyncData(null);
      ref.invalidate(projectDetailsProvider(projectId));
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<WizardResponse> confirmProject(String projectId, ConfirmProjectPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.confirmProject(projectId, payload);
      state = const AsyncData(null);
      ref.invalidate(projectsListProvider);
      ref.invalidate(projectDetailsProvider(projectId));
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<WizardResponse> finalAssignContractor(String projectId, FinalAssignPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.finalAssignContractor(projectId, payload);
      state = const AsyncData(null);
      ref.invalidate(projectsListProvider);
      ref.invalidate(projectDetailsProvider(projectId));
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final projectWizardProvider = AsyncNotifierProvider<ProjectWizardNotifier, void>(ProjectWizardNotifier.new);
