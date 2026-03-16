import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_responses.dart';
import '../../projects/providers/project_providers.dart';
import '../models/marketplace_responses.dart';
import '../repositories/marketplace_repository.dart';

final marketplaceProjectsProvider = FutureProvider.family<PaginatedProjectsResponse, int>((ref, page) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.fetchMarketplaceProjects(page: page);
});

final myBidsProvider = FutureProvider.family<PaginatedBidsResponse, int>((ref, page) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.fetchMyBids(page: page);
});

// Using a record type for multiple arguments
typedef ProjectBidsArgs = ({String projectId, int page});

final projectBidsProvider = FutureProvider.family<PaginatedBidsResponse, ProjectBidsArgs>((ref, args) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.fetchProjectBids(args.projectId, page: args.page);
});

class MarketplaceActionNotifier extends AsyncNotifier<void> {
  late MarketplaceRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(marketplaceRepositoryProvider);
  }

  Future<BidResponse> submitBid(String projectId, SubmitBidPayload payload) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.submitBid(projectId, payload);
      state = const AsyncData(null);
      
      ref.invalidate(marketplaceProjectsProvider);
      ref.invalidate(myBidsProvider);
      // Invalidate the entire family so that any page/project combination refreshes
      ref.invalidate(projectBidsProvider);
      
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<BidResponse> acceptBid(String bidId, {String? projectId}) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.acceptBid(bidId);
      state = const AsyncData(null);
      
      ref.invalidate(marketplaceProjectsProvider);
      ref.invalidate(myBidsProvider);
      if (projectId != null) {
        ref.invalidate(projectBidsProvider);
      }
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<BidResponse> rejectBid(String bidId, {String? projectId}) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.rejectBid(bidId);
      state = const AsyncData(null);
      
      ref.invalidate(marketplaceProjectsProvider);
      ref.invalidate(myBidsProvider);
      if (projectId != null) {
        ref.invalidate(projectBidsProvider);
      }
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<BookmarkResponse> toggleProjectBookmark(String projectId) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.toggleProjectBookmark(projectId);
      state = const AsyncData(null);
      
      ref.invalidate(marketplaceProjectsProvider);
      ref.invalidate(projectDetailsProvider(projectId));
      ref.invalidate(projectsListProvider);

      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final marketplaceActionProvider = AsyncNotifierProvider<MarketplaceActionNotifier, void>(MarketplaceActionNotifier.new);
