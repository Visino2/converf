import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/invoice_models.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InvoiceRepository(ApiClient(dio));
});

class InvoiceRepository {
  final ApiClient _apiClient;

  InvoiceRepository(this._apiClient);

  Future<PaginatedInvoices> getContractorInvoices({int page = 1}) async {
    final response = await _apiClient.get('/api/v1/invoices', queryParameters: {'page': page});

    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format: expected a Map");
    }

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == false) {
      throw Exception(data['message'] ?? 'Failed to load invoices');
    }

    return PaginatedInvoices.fromJson(data);
  }

  Future<Invoice> createInvoice(
      String projectId, Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/api/v1/projects/$projectId/invoices',
      data: payload,
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format: expected a Map");
    }

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == false) {
      throw Exception(data['message'] ?? 'Failed to create invoice');
    }

    final responseData = data['data'] ?? {};
    return Invoice.fromJson(responseData);
  }
}
