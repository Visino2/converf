import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/dio_provider.dart';
import '../models/contractor_models.dart';

class ContractorRepository {
  final ApiClient _apiClient;

  ContractorRepository(this._apiClient);

  Future<ContractorProfileResponse> fetchOwnProfile() async {
    final response = await _apiClient.get('/api/v1/contractor/profile');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    return ContractorProfileResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ContractorProfileResponse> upsertOwnProfile(
    ContractorProfilePayload payload,
  ) async {
    final response = await _apiClient.put(
      '/api/v1/contractor/profile',
      data: payload.toJson(),
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    return ContractorProfileResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ContractorVerificationResponse> fetchVerification() async {
    final response = await _apiClient.get('/api/v1/contractor/verification');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    return ContractorVerificationResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ContractorDocument> uploadVerificationDocument(
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final response = await _apiClient.post(
      '/api/v1/contractor/verification/documents',
      data: formData,
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    final data = response.data as Map<String, dynamic>;
    return ContractorDocument.fromJson(data['data'] ?? data);
  }

  Future<void> deleteVerificationDocument(String documentId) async {
    await _apiClient.delete(
      '/api/v1/contractor/verification/documents/$documentId',
    );
  }
  
  Future<void> addCertification(Map<String, dynamic> data) async {
    await _apiClient.post('/api/v1/contractor/certifications', data: data);
  }

  Future<void> deleteCertification(String certificationId) async {
    await _apiClient.delete('/api/v1/contractor/certifications/$certificationId');
  }

  Future<List<ContractorPortfolioItem>> fetchPortfolio() async {
    final response = await _apiClient.get('/api/v1/contractor/portfolio');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List? ?? [];
    return list
        .whereType<Map>()
        .map((e) => ContractorPortfolioItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ContractorPortfolioItem> createPortfolioItem(
    ContractorPortfolioPayload payload,
  ) async {
    final formData = FormData.fromMap(payload.toJson());

    if (payload.coverImage != null) {
      final path = payload.coverImage.toString();
      formData.files.add(
        MapEntry(
          'cover_image',
          await MultipartFile.fromFile(
            path,
            filename: path.split('/').last,
          ),
        ),
      );
    }

    final response = await _apiClient.post(
      '/api/v1/contractor/portfolio',
      data: formData,
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    final data = response.data as Map<String, dynamic>;
    return ContractorPortfolioItem.fromJson(data['data'] ?? data);
  }

  Future<ContractorPortfolioItem> updatePortfolioItem(
    String itemId,
    ContractorPortfolioPayload payload,
  ) async {
    final formData = FormData.fromMap(payload.toJson());

    if (payload.coverImage != null && payload.coverImage is String && (payload.coverImage as String).isNotEmpty) {
      final path = payload.coverImage as String;
      if (!path.startsWith('http')) {
        formData.files.add(
          MapEntry(
            'cover_image',
            await MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
            ),
          ),
        );
      }
    }

    // Use POST with _method=PUT for multipart updates if needed, 
    // but the web uses PUT directly with FormData.
    final response = await _apiClient.put(
      '/api/v1/contractor/portfolio/$itemId',
      data: formData,
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    final data = response.data as Map<String, dynamic>;
    return ContractorPortfolioItem.fromJson(data['data'] ?? data);
  }

  Future<void> deletePortfolioItem(String itemId) async {
    await _apiClient.delete('/api/v1/contractor/portfolio/$itemId');
  }

  Future<ContractorsResponse> fetchContractors({String? specialisation}) async {
    final response = await _apiClient.get(
      '/api/v1/contractors',
      queryParameters: specialisation != null ? {'specialisation': specialisation} : null,
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
    }
    return ContractorsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

final contractorRepositoryProvider = Provider<ContractorRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ContractorRepository(ApiClient(dio));
});
