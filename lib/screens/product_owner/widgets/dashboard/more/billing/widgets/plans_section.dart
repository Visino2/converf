import 'package:converf/features/billing/models/billing_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/billing_formatters.dart';
import 'error_box.dart';

class PlansSection extends StatefulWidget {
  final AsyncValue<BillingPlansResponse> plansState;
  final BillingSubscription? currentSubscription;
  final AsyncValue<void> actionState;
  final Future<void> Function(String planId) onSelectPlan;
  final VoidCallback onRetry;

  const PlansSection({
    super.key,
    required this.plansState,
    required this.currentSubscription,
    required this.actionState,
    required this.onSelectPlan,
    required this.onRetry,
  });

  @override
  State<PlansSection> createState() => _PlansSectionState();
}

class _PlansSectionState extends State<PlansSection> {
  String? _loadingPlanId;
  String _getPlanDescription(String planName) {
    final lower = planName.toLowerCase();
    if (lower.contains('free') || lower.contains('basic')) {
      return '1 project, 3 team members, 2 GB storage';
    }
    if (lower.contains('starter')) {
      return '10 projects, 20 team members, 20 GB storage';
    }
    if (lower.contains('builder')) {
      return '20 projects, 50 team members, 50 GB storage';
    }
    if (lower.contains('professional')) {
      return '30 projects, 75 team members, 100 GB storage';
    }
    if (lower.contains('elite')) {
      return 'Unlimited projects, Unlimited team members, 500 GB storage';
    }
    if (lower.contains('enterprise')) {
      return 'Unlimited projects, Unlimited team members, 2000 GB storage';
    }
    return 'Upgrade to unlock higher limits.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Plans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        widget.plansState.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: Color(0xFF276572)),
            ),
          ),
          error: (err, _) => ErrorBox(
            title: 'Plans',
            message: err.toString(),
            onRetry: widget.onRetry,
          ),
          data: (plansResp) {
            if (plansResp.plans.isEmpty) {
              return const Text(
                'No plans available yet.',
                style: TextStyle(color: Color(0xFF6B7280)),
              );
            }

            final plans = List<BillingPlan>.from(plansResp.plans);

            plans.sort((a, b) {
              if (a.name.toLowerCase().contains('enterprise')) return 1;
              if (b.name.toLowerCase().contains('enterprise')) return -1;
              return (a.price ?? 0).compareTo(b.price ?? 0);
            });

            return Column(
              children: [
                ...plans.map((plan) {
                  final isCurrent =
                      (widget.currentSubscription?.planId != null &&
                          widget.currentSubscription?.planId == plan.id) ||
                      (widget.currentSubscription?.planName != null &&
                          widget.currentSubscription!.planName!.toLowerCase() ==
                              plan.name.toLowerCase());

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF276572)
                            : const Color(0xFFE5E7EB),
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.label.toTitleCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    priceText(plan),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF276572),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getPlanDescription(plan.name),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF475467),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFABEFC6),
                                  ),
                                ),
                                child: const Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    color: Color(0xFF067647),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF2F4F7)),
                        const SizedBox(height: 16),
                        ...plan.features.entries
                            .where((e) => e.value)
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Color(0xFF0F973D),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        formatFeatureName(e.key),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF475467),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrent
                                  ? const Color(0xFFF2F4F7)
                                  : const Color(0xFF276572),
                              foregroundColor: isCurrent
                                  ? const Color(0xFF667085)
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isCurrent || _loadingPlanId != null
                                ? null
                                : () async {
                                    setState(() => _loadingPlanId = plan.id);
                                    try {
                                      await widget.onSelectPlan(plan.id);
                                    } finally {
                                      if (mounted) {
                                        setState(() => _loadingPlanId = null);
                                      }
                                    }
                                  },
                            child: _loadingPlanId == plan.id
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isCurrent ? 'Current Plan' : 'Choose Plan',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}
