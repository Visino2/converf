import 'package:converf/features/billing/models/billing_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddOnsSection extends StatelessWidget {
  final AsyncValue<BillingPlansResponse> plansState;
  final AsyncValue<void> actionState;
  final Future<PaymentIntent> Function(String category, String packKey) onPurchase;
  final void Function(String reference) onPendingReference;
  final Future<void> Function(String url) onLaunchPayment;

  const AddOnsSection({
    super.key,
    required this.plansState,
    required this.actionState,
    required this.onPurchase,
    required this.onPendingReference,
    required this.onLaunchPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purchase Add-ons',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Need more capacity? Expand your active plan on demand.',
          style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        plansState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const SizedBox(),
          data: (plansResp) {
            final allAddons = <Widget>[];

            plansResp.addonPacks.forEach((category, packs) {
              packs.forEach((key, pack) {
                allAddons.add(_AddonTile(
                  category: category,
                  packKey: key,
                  pack: pack,
                  actionState: actionState,
                  onBuy: () => _handleBuy(context, category, key),
                ));
              });
            });

            if (allAddons.isEmpty) {
              return const Text('No add-ons available.', style: TextStyle(color: Color(0xFF667085)));
            }

            return Column(children: allAddons);
          },
        ),
      ],
    );
  }

  Future<void> _handleBuy(BuildContext context, String category, String packKey) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final intent = await onPurchase(category, packKey);
      onPendingReference(intent.reference);
      await onLaunchPayment(intent.paymentUrl);
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    }
  }
}

class _AddonTile extends StatelessWidget {
  final String category;
  final String packKey;
  final AddonPack pack;
  final AsyncValue<void> actionState;
  final Future<void> Function() onBuy;

  const _AddonTile({
    required this.category,
    required this.packKey,
    required this.pack,
    required this.actionState,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (category == 'storage') {
      icon = Icons.cloud_outlined;
      color = const Color(0xFF309DAA);
    } else if (category == 'team_seats') {
      icon = Icons.people_outline;
      color = const Color(0xFFF79009);
    } else {
      icon = Icons.auto_awesome_outlined;
      color = const Color(0xFF276572);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  '${pack.currency ?? '₦'}${pack.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF276572),
              side: const BorderSide(color: Color(0xFFD0D5DD)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: actionState.isLoading ? null : onBuy,
            child: actionState.isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Buy'),
          ),
        ],
      ),
    );
  }
}
