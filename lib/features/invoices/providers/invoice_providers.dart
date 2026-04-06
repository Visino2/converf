import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/invoice_models.dart';
import '../repositories/invoice_repository.dart';

final contractorInvoicesProvider =
    FutureProvider.autoDispose.family<PaginatedInvoices, int>((ref, page) async {
  final repository = ref.read(invoiceRepositoryProvider);
  return repository.getContractorInvoices(page: page);
});

class InvoiceActionNotifier extends AsyncNotifier<void> {
  late InvoiceRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(invoiceRepositoryProvider);
  }

  Future<void> createInvoice(
      String projectId, Map<String, dynamic> payload) async {
    state = const AsyncLoading();
    try {
      await _repository.createInvoice(projectId, payload);
      // Invalidate the list so it fetches the new data
      ref.invalidate(contractorInvoicesProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final invoiceActionProvider =
    AsyncNotifierProvider<InvoiceActionNotifier, void>(
  InvoiceActionNotifier.new,
);
