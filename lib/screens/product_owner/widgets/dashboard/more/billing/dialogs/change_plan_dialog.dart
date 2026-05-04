import 'package:converf/features/billing/models/billing_models.dart';
import 'package:flutter/material.dart';
import '../utils/billing_formatters.dart';

String _planDescription(String planName) {
  final name = planName.toLowerCase();
  if (name.contains('free')) return 'Basic access · 1 project · limited features';
  if (name.contains('starter')) return '10 projects · team management · AI credits';
  if (name.contains('professional')) return '20 projects · advanced tools · priority support';
  if (name.contains('elite')) return 'Unlimited projects · elite support · all features · Free QAQC Training (3 seats)';
  if (name.contains('builder')) return 'Unlimited projects · advanced analytics · priority support';
  if (name.contains('enterprise')) return 'Custom limits · dedicated support · SLA guarantee · Free QAQC Training (10 seats)';
  return 'Contact us for details';
}

class ChangePlanDialog extends StatefulWidget {
  final BillingSubscription currentSubscription;
  final List<BillingPlan> plans;
  final Function(String planId) onConfirm;
  final bool isLoading;

  const ChangePlanDialog({
    super.key,
    required this.currentSubscription,
    required this.plans,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  State<ChangePlanDialog> createState() => _ChangePlanDialogState();
}

class _ChangePlanDialogState extends State<ChangePlanDialog> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final currentPlanId = widget.currentSubscription.planId;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 50,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium Header with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF309DAA), Color(0xFF1E6B75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
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
                            const Text(
                              'Upgrade Your Plan',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Unlock more features and maximize your potential',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Plan Selection List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Plans',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final plan in widget.plans)
                      _buildPlanCard(plan, currentPlanId),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF2F4F7)),

            // Footer Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFD0D5DD),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: widget.isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF309DAA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: (_selectedPlanId != null && !widget.isLoading)
                          ? () {
                              widget.onConfirm(_selectedPlanId!);
                              Navigator.pop(context);
                            }
                          : null,
                      child: widget.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm Change',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BillingPlan plan, String? currentPlanId) {
    final isCurrentPlan = plan.id == currentPlanId;
    final isSelected = _selectedPlanId == plan.id;

    return GestureDetector(
      onTap: isCurrentPlan
          ? null
          : () {
              setState(() => _selectedPlanId = plan.id);
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF309DAA)
                : isCurrentPlan
                ? const Color(0xFFABEFC6)
                : const Color(0xFFE5E7EB),
            width: isSelected || isCurrentPlan ? 2.5 : 1.5,
          ),
          color: isCurrentPlan
              ? const Color(0xFFFCFCFD)
              : isSelected
              ? const Color(0xFFF0F9FF)
              : Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (!isCurrentPlan)
              // ignore: deprecated_member_use
              Radio<String>(
                value: plan.id,
                // ignore: deprecated_member_use
                groupValue: _selectedPlanId,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() => _selectedPlanId = value);
                },
                activeColor: const Color(0xFF309DAA),
                fillColor: WidgetStateProperty.all(const Color(0xFF309DAA)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFABEFC6)),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF067647),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.label
                        .replaceAll('_', ' ')
                        .split(' ')
                        .map(
                          (word) => word.isEmpty
                              ? ''
                              : word[0].toUpperCase() +
                                    (word.length > 1 ? word.substring(1) : ''),
                        )
                        .join(' '),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _planDescription(plan.name),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    priceText(plan),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF309DAA),
                    ),
                  ),
                  if (!plan.name.toLowerCase().contains('free') &&
                      !plan.name.toLowerCase().contains('basic')) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFABEFC6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 11, color: Color(0xFF067647)),
                          SizedBox(width: 3),
                          Text(
                            'Free Setup & Training',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF067647),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
