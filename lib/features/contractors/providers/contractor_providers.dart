import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contractor_models.dart';
import '../repositories/contractor_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for fetching the list of contractors.
/// Mirrors the React `useContractors(specialisation?: string)` hook. 
final contractorsProvider = FutureProvider.family<ContractorsResponse, String?>((ref, specialisation) async {
  final repository = ref.read(contractorRepositoryProvider);
  return repository.fetchContractors(specialisation: specialisation);
});

/// Fetch the authenticated contractor's own profile.
final contractorProfileProvider = FutureProvider<ContractorProfileResponse>(
  (ref) async {
    final repository = ref.read(contractorRepositoryProvider);
    return repository.fetchOwnProfile();
  },
);

/// Fetch the contractor verification tracker/documents.
final contractorVerificationProvider =
    FutureProvider<ContractorVerificationResponse>((ref) async {
  final repository = ref.read(contractorRepositoryProvider);
  return repository.fetchVerification();
});

class ContractorProfileNotifier extends AsyncNotifier<void> {
  late ContractorRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(contractorRepositoryProvider);
  }

  Future<void> upsertProfile(ContractorProfilePayload payload) async {
    state = const AsyncLoading();
    try {
      final updated = await _repository.upsertOwnProfile(payload);
      
      // Update session to keep local state in sync
      // Update session to keep local state in sync (safe merge preserves roles)
      await ref.read(authProvider.notifier).updateCurrentUser(updated.data.toJson());
      
      ref.invalidate(contractorProfileProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> uploadDocument(String filePath) async {
    state = const AsyncLoading();
    try {
      await _repository.uploadVerificationDocument(filePath);
      ref.invalidate(contractorVerificationProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteVerificationDocument(documentId);
      ref.invalidate(contractorVerificationProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> addCertification(Map<String, dynamic> payload) async {
    state = const AsyncLoading();
    try {
      await _repository.addCertification(payload);
      ref.invalidate(contractorProfileProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteCertification(String certificationId) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteCertification(certificationId);
      ref.invalidate(contractorProfileProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

/// Fetch the authenticated contractor's portfolio items.
final contractorPortfolioProvider = FutureProvider<List<ContractorPortfolioItem>>(
  (ref) async {
    final repository = ref.read(contractorRepositoryProvider);
    return repository.fetchPortfolio();
  },
);

class PortfolioNotifier extends AsyncNotifier<void> {
  late ContractorRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(contractorRepositoryProvider);
  }

  Future<void> createItem(ContractorPortfolioPayload payload) async {
    state = const AsyncLoading();
    try {
      await _repository.createPortfolioItem(payload);
      ref.invalidate(contractorPortfolioProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateItem(String id, ContractorPortfolioPayload payload) async {
    state = const AsyncLoading();
    try {
      await _repository.updatePortfolioItem(id, payload);
      ref.invalidate(contractorPortfolioProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    state = const AsyncLoading();
    try {
      await _repository.deletePortfolioItem(id);
      ref.invalidate(contractorPortfolioProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final portfolioNotifierProvider =
    AsyncNotifierProvider<PortfolioNotifier, void>(
  PortfolioNotifier.new,
);

final contractorProfileNotifierProvider =
    AsyncNotifierProvider<ContractorProfileNotifier, void>(
  ContractorProfileNotifier.new,
);
