import 'package:converf/features/billing/models/billing_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/billing_formatters.dart';
import 'error_box.dart';

class TransactionsSection extends StatelessWidget {
  final AsyncValue<PaginatedTransactions> state;
  final int currentPage;
  final VoidCallback onRetry;
  final void Function(int page) onPageChanged;

  const TransactionsSection({
    super.key,
    required this.state,
    required this.currentPage,
    required this.onRetry,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        state.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: Color(0xFF276572)),
            ),
          ),
          error: (err, _) => ErrorBox(
            title: 'Transactions',
            message: err.toString(),
            onRetry: onRetry,
          ),
          data: (txns) {
            if (txns.data.isEmpty) {
              return const Text(
                'No transactions yet.',
                style: TextStyle(color: Color(0xFF6B7280)),
              );
            }

            final meta = txns.meta;
            final int current = (meta['current_page'] ?? meta['page'] ?? currentPage) is int
                ? (meta['current_page'] ?? meta['page'] ?? currentPage) as int
                : int.tryParse((meta['current_page'] ?? meta['page'] ?? currentPage).toString()) ?? currentPage;
            final int lastPage = (meta['last_page'] ?? meta['total_pages'] ?? current) is int
                ? (meta['last_page'] ?? meta['total_pages'] ?? current) as int
                : int.tryParse((meta['last_page'] ?? meta['total_pages'] ?? current).toString()) ?? current;

            return Column(
              children: [
                ...txns.data.map(
                  (t) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDate(t.createdAt),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.status ?? 'pending',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: (t.status ?? '').toLowerCase() == 'paid'
                                    ? const Color(0xFF0F973D)
                                    : const Color(0xFFB54708),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${t.currency ?? '₦'} ${t.amount}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Page $current of $lastPage', style: const TextStyle(color: Color(0xFF6B7280))),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: current > 1 ? () => onPageChanged(current - 1) : null,
                          child: const Text('Prev'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: current < lastPage ? () => onPageChanged(current + 1) : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
