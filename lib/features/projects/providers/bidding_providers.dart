import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bid.dart';
import '../repositories/bidding_repository.dart';
import 'project_providers.dart';

final projectBidsProvider = FutureProvider.family<List<Bid>, String>((ref, projectId) async {
  final repository = ref.read(biddingRepositoryProvider);
  final response = await repository.fetchBids(projectId);
  return response.data;
});

final bidDetailsProvider = FutureProvider.family<Bid, String>((ref, bidId) async {
  final repository = ref.read(biddingRepositoryProvider);
  final response = await repository.fetchBidById(bidId);
  return response.data;
});

class BiddingNotifier extends AsyncNotifier<void> {
  late BiddingRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(biddingRepositoryProvider);
  }

  Future<void> submitBid({
    required String projectId,
    required double amount,
    required String proposal,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.submitBid(
        projectId: projectId,
        amount: amount,
        proposal: proposal,
      );
      state = const AsyncData(null);
      ref.invalidate(projectBidsProvider(projectId));
      // Optionally invalidate project details if bids_count is used
      ref.invalidate(projectDetailsProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> acceptBid(String bidId, String projectId) async {
    state = const AsyncLoading();
    try {
      await _repository.acceptBid(bidId);
      state = const AsyncData(null);
      ref.invalidate(projectBidsProvider(projectId));
      ref.invalidate(projectDetailsProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> rejectBid(String bidId, String projectId) async {
    state = const AsyncLoading();
    try {
      await _repository.rejectBid(bidId);
      state = const AsyncData(null);
      ref.invalidate(projectBidsProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final biddingNotifierProvider = AsyncNotifierProvider<BiddingNotifier, void>(BiddingNotifier.new);
