import 'package:converf/features/billing/models/billing_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/billing_formatters.dart';
import 'error_box.dart';

class SubscriptionCardSection extends StatelessWidget {
  final AsyncValue<BillingSubscription> subscriptionState;
  final AsyncValue<BillingPlansResponse> plansState;
  final AsyncValue<void> actionState;
  final Future<void> Function(String) onStartPlan;
  final Future<void> Function() onCancel;
  final VoidCallback onRetry;

  const SubscriptionCardSection({
    super.key,
    required this.subscriptionState,
    required this.plansState,
    required this.actionState,
    required this.onStartPlan,
    required this.onCancel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return subscriptionState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF276572)),
      ),
      error: (err, _) => ErrorBox(
        title: 'Subscription',
        message: err.toString(),
        onRetry: onRetry,
      ),
      data: (sub) {
        final hasPlan = (sub.planName ?? '').isNotEmpty;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF309DAA), width: 1),
              gradient: const LinearGradient(
                colors: [Color(0xFF309DAA), Color(0xFF2A8090)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _CrossPatternPainter())),
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Image.asset(
                    'assets/images/vector-2.png',
                    width: 491,
                    height: 252,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: hasPlan ? const Color(0xFF0F973D) : const Color(0xFFF79009),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hasPlan ? 'Active Plan' : 'No Active Plan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hasPlan ? (sub.planName ?? 'Subscription') : 'Choose a plan to continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasPlan
                            ? 'Status: ${sub.status ?? 'active'}  ·  Renews: ${formatDate(sub.renewsAt)}'
                            : 'Start a plan to unlock full billing features.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF276572),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: actionState.isLoading
                                ? null
                                : () async {
                                    final plans = plansState.asData?.value;
                                    final defaultPlan = plans?.plans.isNotEmpty == true ? plans!.plans.first : null;
                                    if (defaultPlan == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No plans available yet.')),
                                      );
                                      return;
                                    }
                                    await onStartPlan(defaultPlan.id);
                                  },
                            child: actionState.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(hasPlan ? 'Change Plan' : 'Start Plan'),
                          ),
                          const SizedBox(width: 12),
                          if (hasPlan)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: actionState.isLoading ? null : onCancel,
                              child: const Text('Cancel'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CrossPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 28.0;
    const crossSize = 8.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawLine(
          Offset(x - crossSize, y),
          Offset(x + crossSize, y),
          paint,
        );
        canvas.drawLine(
          Offset(x, y - crossSize),
          Offset(x, y + crossSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
