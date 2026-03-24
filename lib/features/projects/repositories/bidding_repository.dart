import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/bid.dart';

final biddingRepositoryProvider = Provider<BiddingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BiddingRepository(ApiClient(dio));
});

class BiddingRepository {
  final ApiClient _apiClient;

  BiddingRepository(this._apiClient);

  Future<BidListResponse> fetchBids(String projectId) async {
    final response = await _apiClient.get('/api/v1/projects/$projectId/bids');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return BidListResponse.fromJson(response.data);
  }

  Future<BidResponse> submitBid({
    required String projectId,
    required double amount,
    required String proposal,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/projects/$projectId/bids',
      data: {
        'amount': amount,
        'proposal': proposal,
      },
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return BidResponse.fromJson(response.data);
  }

  Future<BidResponse> fetchBidById(String bidId) async {
    final response = await _apiClient.get('/api/v1/bids/$bidId');
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return BidResponse.fromJson(response.data);
  }

  Future<void> acceptBid(String bidId) async {
    await _apiClient.patch('/api/v1/bids/$bidId/accept');
  }

  Future<void> rejectBid(String bidId) async {
    await _apiClient.patch('/api/v1/bids/$bidId/reject');
  }
}
