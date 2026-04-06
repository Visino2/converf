import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_responses.dart';
import '../../projects/providers/project_providers.dart';
import '../models/marketplace_responses.dart';
import '../models/marketplace_filters.dart';
import '../repositories/marketplace_repository.dart';

class MarketplaceFiltersNotifier extends Notifier<MarketplaceFilters> {
  @override
  MarketplaceFilters build() => MarketplaceFilters();

  void update(MarketplaceFilters Function(MarketplaceFilters) cb) {
    state = cb(state);
  }

  set state(MarketplaceFilters value) => super.state = value;
}

final marketplaceFiltersProvider = NotifierProvider<MarketplaceFiltersNotifier, MarketplaceFilters>(MarketplaceFiltersNotifier.new);

typedef MarketplaceArgs = ({int page, MarketplaceFilters filters});

final marketplaceProjectsProvider = FutureProvider.family<PaginatedProjectsResponse, MarketplaceArgs>((ref, args) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return repository.fetchMarketplaceProjects(page: args.page, filters: args.filters);
});

final myBidsProvider = FutureProvider.family<PaginatedBidsResponse, int>((ref, page) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return repository.fetchMyBids(page: page);
});

// Using a record type for multiple arguments
typedef ProjectBidsArgs = ({String projectId, int page});

final projectBidsProvider = FutureProvider.family<PaginatedBidsResponse, ProjectBidsArgs>((ref, args) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return repository.fetchProjectBids(args.projectId, page: args.page);
});

bool _isOpenBidStatus(String status) {
  final normalized = status.trim().toLowerCase();
  return normalized != 'accepted' &&
      normalized != 'rejected' &&
      normalized != 'declined';
}

final projectOpenBidsCountProvider = FutureProvider.family<int, String>((ref, projectId) async {
  final response = await ref.watch(
    projectBidsProvider((projectId: projectId, page: 1)).future,
  );
  return response.data.where((bid) => _isOpenBidStatus(bid.status)).length;
});

class MarketplaceActionNotifier extends AsyncNotifier<void> {
  late MarketplaceRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(marketplaceRepositoryProvider);
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
        ref.invalidate(projectOpenBidsCountProvider(projectId));
        ref.invalidate(projectDetailsProvider(projectId));
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
        ref.invalidate(projectOpenBidsCountProvider(projectId));
        ref.invalidate(projectDetailsProvider(projectId));
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
