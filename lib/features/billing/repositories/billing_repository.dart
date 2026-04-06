import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/dio_provider.dart';
import '../models/billing_models.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BillingRepository(ApiClient(dio));
});

class BillingRepository {
  final ApiClient _apiClient;

  BillingRepository(this._apiClient);

  Future<PaginatedTransactions> fetchTransactions({int? page}) async {
    final response = await _apiClient.get(
      '/api/v1/billing/transactions',
      queryParameters: page != null ? {'page': page} : null,
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    return PaginatedTransactions.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<BillingPlansResponse> fetchPlans() async {
    final response = await _apiClient.get('/api/v1/billing/plans');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    return BillingPlansResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BillingSubscription> fetchSubscription() async {
    final response = await _apiClient.get('/api/v1/billing/subscription');
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    return BillingSubscription.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentIntent> subscribe(String planId) async {
    final response = await _apiClient.post(
      '/api/v1/billing/subscribe',
      data: {'plan_id': planId},
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    return PaymentIntent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelSubscription() async {
    await _apiClient.post('/api/v1/billing/cancel', data: {});
  }

  Future<void> verifyPayment(String reference) async {
    await _apiClient.post(
      '/api/v1/billing/verify',
      data: {'reference': reference},
    );
  }

  Future<PaymentIntent> purchaseAddon(String path, String packKey) async {
    final response = await _apiClient.post(
      path,
      data: {'pack_key': packKey},
    );
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }
    return PaymentIntent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentIntent> purchaseStorageAddon(String packKey) {
    return purchaseAddon('/api/v1/billing/addons/storage', packKey);
  }

  Future<PaymentIntent> purchaseSeatAddon(String packKey) {
    return purchaseAddon('/api/v1/billing/addons/team-seats', packKey);
  }

  Future<PaymentIntent> purchaseAiCreditsAddon(String packKey) {
    return purchaseAddon('/api/v1/billing/addons/ai-credits', packKey);
  }
}
