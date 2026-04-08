import 'package:converf/features/ai_credits/models/ai_credits_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiCreditsSection extends StatelessWidget {
  final AsyncValue<AiCreditsBalance> state;
  final VoidCallback onRetry;

  const AiCreditsSection({
    super.key,
    required this.state,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: state.when(
        loading: () => const SizedBox(
          height: 76,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF276572)),
          ),
        ),
        error: (error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Advisory Credits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load your AI credit balance right now: $error',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB42318),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF276572),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Try again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        data: (balance) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF276572),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Advisory Credits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Available for Converf AI project guidance',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance.displayValue,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    balance.isUnlimited ? 'plan access' : 'credits left',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              balance.summaryText,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475467),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
