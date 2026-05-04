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

  String _getPlanDescription(String planName, BillingPlan? planData) {
    // If we have plan data with features, use those as a list
    if (planData?.features != null && planData!.features.isNotEmpty) {
      final featuresList = planData.features.keys
          .where((key) => planData.features[key] == true)
          .map((key) => key.replaceAll('_', ' ').toTitleCase())
          .toList();
      if (featuresList.isNotEmpty) {
        return featuresList.join(', ');
      }
    }

    // Fallback to hardcoded descriptions based on plan name
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
      return 'Unlimited projects, Unlimited team members, 500 GB storage · Free QAQC Training (3 seats)';
    }
    if (lower.contains('enterprise')) {
      return 'Unlimited projects, Unlimited team members, 2000 GB storage · Free QAQC Training (10 seats)';
    }
    return 'Upgrade to unlock higher limits.';
  }

  String _getPricingText(BillingPlan plan) {
    final monthlyPrice = plan.price ?? 0;
    final yearlyPrice = (monthlyPrice * 12 * 0.9).toStringAsFixed(0);
    final currency = plan.currency ?? '₦';

    if (monthlyPrice > 0) {
      return '$currency${monthlyPrice.toStringAsFixed(0)}/month or $currency$yearlyPrice/year (10% savings)';
    }
    return 'Contact for pricing';
  }

  bool _isFreePlan(BillingPlan plan) {
    final lower = plan.name.toLowerCase();
    return lower.contains('free') ||
        lower.contains('basic') ||
        (plan.price ?? 0) == 0;
  }

  bool _isCurrentPlanPaid() {
    if (widget.currentSubscription == null) return false;
    final currentPlanName =
        widget.currentSubscription!.planName?.toLowerCase() ?? '';
    return !currentPlanName.contains('free') &&
        !currentPlanName.contains('basic');
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
                                    _getPricingText(plan),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF276572),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getPlanDescription(plan.name, plan),
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
                        if (!plan.name.toLowerCase().contains('free') &&
                            !plan.name.toLowerCase().contains('basic')) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFABEFC6),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: Color(0xFF067647),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Free Setup & Training Included',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF067647),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          child: Tooltip(
                            message: (_isFreePlan(plan) && _isCurrentPlanPaid())
                                ? 'Cannot change to Free plan. Use Cancel Subscription instead.'
                                : '',
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrent
                                    ? const Color(0xFFF2F4F7)
                                    : ((_isFreePlan(plan) &&
                                              _isCurrentPlanPaid())
                                          ? const Color(0xFFE5E7EB)
                                          : const Color(0xFF276572)),
                                foregroundColor: isCurrent
                                    ? const Color(0xFF667085)
                                    : ((_isFreePlan(plan) &&
                                              _isCurrentPlanPaid())
                                          ? const Color(0xFF9CA3AF)
                                          : Colors.white),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed:
                                  isCurrent ||
                                      _loadingPlanId != null ||
                                      (_isFreePlan(plan) &&
                                          _isCurrentPlanPaid())
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
                                      isCurrent
                                          ? 'Current Plan'
                                          : 'Choose Plan',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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
