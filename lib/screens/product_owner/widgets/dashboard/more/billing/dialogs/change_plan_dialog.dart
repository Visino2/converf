import 'package:converf/features/billing/models/billing_models.dart';
import 'package:flutter/material.dart';
import '../utils/billing_formatters.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Change Plan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a new plan to upgrade or downgrade your subscription',
                    style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF2F4F7)),

            // Plan Selection
            SizedBox(
              height: 350,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ...widget.plans.map((plan) {
                      final isCurrentPlan = plan.id == currentPlanId;
                      final isSelected = _selectedPlanId == plan.id;

                      return GestureDetector(
                        onTap: isCurrentPlan
                            ? null
                            : () {
                                setState(() => _selectedPlanId = plan.id);
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF276572)
                                  : isCurrentPlan
                                  ? const Color(0xFFABEFC6)
                                  : const Color(0xFFE5E7EB),
                              width: isSelected || isCurrentPlan ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isCurrentPlan
                                ? const Color(0xFFFCFCFD)
                                : isSelected
                                ? const Color(0xFFF0F9FF)
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              if (!isCurrentPlan)
                                Radio<String>(
                                  value: plan.id,
                                  groupValue: _selectedPlanId,
                                  onChanged: (value) {
                                    setState(() => _selectedPlanId = value);
                                  },
                                  activeColor: const Color(0xFF276572),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFABEFC6),
                                      ),
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
                              const SizedBox(width: 12),
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
                                                      (word.length > 1
                                                          ? word.substring(1)
                                                          : ''),
                                          )
                                          .join(' '),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      priceText(plan),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF276572),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF2F4F7)),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD0D5DD)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276572),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm Change',
                              style: TextStyle(fontWeight: FontWeight.w600),
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
}
