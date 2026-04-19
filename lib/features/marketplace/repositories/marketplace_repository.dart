import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';
import '../../../core/api/dio_provider.dart';
import '../../../core/api/api_client.dart';
import '../../projects/models/project_responses.dart';
import '../models/marketplace_responses.dart';
import '../models/marketplace_filters.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MarketplaceRepository(ApiClient(dio));
});

class MarketplaceRepository {
  final ApiClient _apiClient;

  MarketplaceRepository(this._apiClient);

  Future<PaginatedProjectsResponse> fetchMarketplaceProjects({
    int page = 1,
    MarketplaceFilters? filters,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page};
    if (filters != null) {
      queryParams.addAll(filters.toJson());
    }

    final response = await _apiClient.get(
      '/api/v1/marketplace/projects',
      queryParameters: queryParams,
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return PaginatedProjectsResponse.fromJson(response.data);
  }

  Future<PaginatedBidsResponse> fetchMyBids({int page = 1}) async {
    final response = await _apiClient.get(
      '/api/v1/my-bids',
      queryParameters: {'page': page},
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return PaginatedBidsResponse.fromJson(response.data);
  }

  Future<BidResponse> submitBid(String projectId, SubmitBidPayload payload) async {
    dynamic data;
    if (payload.documentPaths != null && payload.documentPaths!.isNotEmpty) {
      final formData = FormData.fromMap(payload.toJson());
      for (final path in payload.documentPaths!) {
        formData.files.add(MapEntry(
          'documents[]',
          await MultipartFile.fromFile(path),
        ));
      }
      data = formData;
    } else {
      data = payload.toJson();
    }

    final response = await _apiClient.post(
      '/api/v1/projects/$projectId/bids',
      data: data,
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    final responseData = response.data as Map<String, dynamic>;
    if (responseData['status'] == false) {
       throw Exception(responseData['message'] ?? 'Failed to submit bid');
    }
    return BidResponse.fromJson(responseData);
  }

  Future<PaginatedBidsResponse> fetchProjectBids(String projectId, {int page = 1}) async {
    final response = await _apiClient.get(
      '/api/v1/projects/$projectId/bids',
      queryParameters: {'page': page},
    );
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return PaginatedBidsResponse.fromJson(response.data);
  }

  Future<BidResponse> acceptBid(String bidId) async {
    final response = await _apiClient.patch('/api/v1/bids/$bidId/accept');
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    final data = response.data as Map<String, dynamic>;
    if (data['status'] == false) {
       throw Exception(data['message'] ?? 'Failed to accept bid');
    }
    return BidResponse.fromJson(data);
  }

  Future<BidResponse> rejectBid(String bidId) async {
    final response = await _apiClient.patch('/api/v1/bids/$bidId/reject');
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    final data = response.data as Map<String, dynamic>;
    if (data['status'] == false) {
       throw Exception(data['message'] ?? 'Failed to decline bid');
    }
    return BidResponse.fromJson(data);
  }

  Future<BookmarkResponse> toggleProjectBookmark(String projectId) async {
    final response = await _apiClient.post('/api/v1/projects/$projectId/bookmark');
    if (response.data is! Map<String, dynamic>) {
        throw Exception("Invalid response format from server");
    }
    return BookmarkResponse.fromJson(response.data);
  }
}
