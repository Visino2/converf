import 'dart:async';

import 'package:converf/core/config/shared_prefs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/billing_models.dart';
import '../repositories/billing_repository.dart';

class PendingPaymentReferenceNotifier extends Notifier<String?> {
  static const _storageKey = 'pending_payment_reference';
  late final SharedPreferences _prefs;

  @override
  String? build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return _prefs.getString(_storageKey);
  }

  void setReference(String? value) {
    final normalizedValue = value?.trim();
    state = (normalizedValue == null || normalizedValue.isEmpty)
        ? null
        : normalizedValue;

    if (state == null) {
      unawaited(_prefs.remove(_storageKey));
      return;
    }

    unawaited(_prefs.setString(_storageKey, state!));
  }

  void clear() => setReference(null);
}

final pendingPaymentReferenceProvider =
    NotifierProvider<PendingPaymentReferenceNotifier, String?>(
      PendingPaymentReferenceNotifier.new,
    );

final billingTransactionsProvider = FutureProvider.autoDispose
    .family<PaginatedTransactions, int?>((ref, page) async {
      final repository = ref.read(billingRepositoryProvider);
      return repository.fetchTransactions(page: page);
    });

final billingPlansProvider = FutureProvider.autoDispose<BillingPlansResponse>((
  ref,
) async {
  final repository = ref.read(billingRepositoryProvider);
  return repository.fetchPlans();
});

final billingSubscriptionProvider =
    FutureProvider.autoDispose<BillingSubscription>((ref) async {
      final repository = ref.read(billingRepositoryProvider);
      return repository.fetchSubscription();
    });

class BillingActionNotifier extends AsyncNotifier<void> {
  late BillingRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(billingRepositoryProvider);
  }

  Future<PaymentIntent> subscribe(String planId) async {
    state = const AsyncLoading();
    try {
      final intent = await _repository.subscribe(planId);
      ref.invalidate(billingSubscriptionProvider);
      state = const AsyncData(null);
      return intent;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> verify(String reference) async {
    state = const AsyncLoading();
    try {
      await _repository.verifyPayment(reference);
      ref.invalidate(billingSubscriptionProvider);
      ref.invalidate(billingTransactionsProvider);
      ref.read(pendingPaymentReferenceProvider.notifier).clear();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> cancel() async {
    state = const AsyncLoading();
    try {
      await _repository.cancelSubscription();
      ref.invalidate(billingSubscriptionProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<PaymentIntent> buyStorage(String packKey) =>
      _buyAddon(() => _repository.purchaseStorageAddon(packKey));

  Future<PaymentIntent> buySeats(String packKey) =>
      _buyAddon(() => _repository.purchaseSeatAddon(packKey));

  Future<PaymentIntent> buyAiCredits(String packKey) =>
      _buyAddon(() => _repository.purchaseAiCreditsAddon(packKey));

  Future<PaymentIntent> _buyAddon(Future<PaymentIntent> Function() fn) async {
    state = const AsyncLoading();
    try {
      final intent = await fn();
      state = const AsyncData(null);
      return intent;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final billingActionProvider =
    AsyncNotifierProvider<BillingActionNotifier, void>(
      BillingActionNotifier.new,
    );
