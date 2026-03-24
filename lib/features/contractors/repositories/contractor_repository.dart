import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/dio_provider.dart';
import '../models/contractor_models.dart';

class ContractorRepository {
  final ApiClient _apiClient;

  ContractorRepository(this._apiClient);

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
