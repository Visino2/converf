import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../features/ai_credits/models/ai_credits_models.dart';
import '../../../../../features/ai_credits/providers/ai_credits_provider.dart';
import '../../../../../features/billing/models/billing_models.dart';
import '../../../../../features/billing/providers/billing_providers.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingPayment();
    }
  }

  void _checkPendingPayment() {
    final pendingRef = ref.read(pendingPaymentReferenceProvider);
    if (pendingRef != null) {
      ref.read(billingActionProvider.notifier).verify(pendingRef);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiCreditsState = ref.watch(aiCreditsProvider);
    final subscriptionState = ref.watch(billingSubscriptionProvider);
    final plansState = ref.watch(billingPlansProvider);
    final transactionsState = ref.watch(billingTransactionsProvider(null));
    final actionState = ref.watch(billingActionProvider);
    final pendingRef = ref.watch(pendingPaymentReferenceProvider);

    final subData = subscriptionState.asData?.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Project Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Billing & Subscription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your professional Converf subscription plan',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),
            _buildAiCreditsSection(aiCreditsState),
            const SizedBox(height: 24),
            _buildSubscriptionCard(subscriptionState, plansState, actionState),
            const SizedBox(height: 24),
            if (subData?.limits != null) ...[
              _buildUsageSection(subData!.limits!),
              const SizedBox(height: 24),
            ],
            if (pendingRef != null) ...[
              _buildPendingVerification(pendingRef, actionState),
              const SizedBox(height: 24),
            ],
            _buildPlans(plansState, subData, actionState),
            const SizedBox(height: 32),
            _buildAddOns(plansState, actionState),
            const SizedBox(height: 32),
            _buildTransactions(transactionsState),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingVerification(String reference, AsyncValue<void> actionState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF276572)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Awaiting payment confirmation...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF276572),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: actionState.isLoading
                ? null
                : () => ref.read(billingActionProvider.notifier).verify(reference),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: actionState.isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Verify Now', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Sections
  // ----------------------------

  Widget _buildAiCreditsSection(
    AsyncValue<AiCreditsBalance> aiCreditsState,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: aiCreditsState.when(
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
              onPressed: () => ref.invalidate(aiCreditsProvider),
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

  Widget _buildUsageSection(BillingLimits limits) {
    final storage = limits.storage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usage & Limits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressBar(
            label: 'Total Storage',
            used: '${storage.usedGb.toStringAsFixed(1)} GB',
            total: '${storage.allowedGb.toStringAsFixed(0)} GB',
            percentage: storage.usagePercentage,
            icon: Icons.cloud_outlined,
          ),
          const SizedBox(height: 20),
          _buildProgressBar(
            label: 'Team Members',
            used: '${limits.teamMembers ?? 0}',
            total: '${limits.maxProjects ?? '∞'}',
            percentage: (limits.teamMembers ?? 0) / (limits.maxProjects ?? 1).toDouble(),
            icon: Icons.people_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required String used,
    required String total,
    required double percentage,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF667085)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
            const Spacer(),
            Text(
              '$used / $total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFF2F4F7),
            valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.9 ? const Color(0xFFD92D20) : const Color(0xFF276572)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(
    AsyncValue<BillingSubscription> subscriptionState,
    AsyncValue<BillingPlansResponse> plansState,
    AsyncValue<void> actionState,
  ) {
    return subscriptionState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF276572)),
      ),
      error: (err, _) => _errorBox(
        title: 'Subscription',
        message: err.toString(),
        onRetry: () => ref.invalidate(billingSubscriptionProvider),
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
                            ? 'Status: ${sub.status ?? 'active'}  ·  Renews: ${_formatDate(sub.renewsAt)}'
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
                                    await _startSubscription(defaultPlan.id);
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
                              onPressed: actionState.isLoading
                                  ? null
                                      : () async {
                                          try {
                                            await ref.read(billingActionProvider.notifier).cancel();
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Subscription cancelled')),
                                            );
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Cancel failed: $e')),
                                            );
                                          }
                                        },
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

  Widget _buildPlans(
    AsyncValue<BillingPlansResponse> plansState,
    BillingSubscription? currentSubscription,
    AsyncValue<void> actionState,
  ) {
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
        plansState.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: Color(0xFF276572)),
            ),
          ),
          error: (err, _) => _errorBox(
            title: 'Plans',
            message: err.toString(),
            onRetry: () => ref.invalidate(billingPlansProvider),
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
              children: plans.map((plan) {
                final isCurrent = (currentSubscription?.planId != null &&
                        currentSubscription?.planId == plan.id) ||
                    (currentSubscription?.planName != null &&
                        currentSubscription!.planName!.toLowerCase() ==
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
                                  _priceText(plan),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF276572),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFABEFC6)),
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
                      ...plan.features.entries.where((e) => e.value).map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFF0F973D)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formatFeatureName(e.key),
                                style: const TextStyle(fontSize: 14, color: Color(0xFF475467)),
                              ),
                            ),
                          ],
                        ),
                      )),
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
                          onPressed: isCurrent || actionState.isLoading
                              ? null
                              : () => _startSubscription(plan.id),
                          child: Text(
                            isCurrent ? 'Current Plan' : 'Choose Plan',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  String _formatFeatureName(String key) {
    return key.replaceAll('_', ' ').toTitleCase();
  }

  Widget _buildAddOns(
    AsyncValue<BillingPlansResponse> plansState,
    AsyncValue<void> actionState,
  ) {
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
                allAddons.add(_buildAddonTile(category, key, pack, actionState));
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

  Widget _buildAddonTile(
    String category,
    String key,
    AddonPack pack,
    AsyncValue<void> actionState,
  ) {
    IconData icon;
    Color color;
    Future<PaymentIntent> Function() action;

    if (category == 'storage') {
      icon = Icons.cloud_outlined;
      color = const Color(0xFF309DAA);
      action = () => ref.read(billingActionProvider.notifier).buyStorage(key);
    } else if (category == 'team_seats') {
      icon = Icons.people_outline;
      color = const Color(0xFFF79009);
      action = () => ref.read(billingActionProvider.notifier).buySeats(key);
    } else {
      icon = Icons.auto_awesome_outlined;
      color = const Color(0xFF276572);
      action = () => ref.read(billingActionProvider.notifier).buyAiCredits(key);
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
            onPressed: actionState.isLoading
                ? null
                : () async {
                    try {
                      final intent = await action();
                      ref.read(pendingPaymentReferenceProvider.notifier).setReference(intent.reference);
                      await _launchPayment(intent.paymentUrl);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Purchase failed: $e')),
                      );
                    }
                  },
            child: actionState.isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Buy'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions(AsyncValue<PaginatedTransactions> txnsState) {
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
        txnsState.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: Color(0xFF276572)),
            ),
          ),
          error: (err, _) => _errorBox(
            title: 'Transactions',
            message: err.toString(),
            onRetry: () {},
          ),
          data: (txns) {
            if (txns.data.isEmpty) {
              return const Text(
                'No transactions yet.',
                style: TextStyle(color: Color(0xFF6B7280)),
              );
            }
            return Column(
              children: txns.data
                  .map(
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
                                _formatDate(t.createdAt),
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
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _startSubscription(
    String planId,
  ) async {
    try {
      final intent =
          await ref.read(billingActionProvider.notifier).subscribe(planId);
      ref.read(pendingPaymentReferenceProvider.notifier).setReference(intent.reference);
      if (!mounted) return;
      await _launchPayment(intent.paymentUrl);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription failed: $e')),
      );
    }
  }

  Future<void> _launchPayment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open payment link')),
      );
    }
  }

  String _priceText(BillingPlan plan) {
    if (plan.price == null || plan.price == 0) {
      if (plan.name.toLowerCase().contains('enterprise')) {
        return 'Contact sales for custom pricing';
      }
      return 'Premium Plan';
    }
    final currency = plan.currency ?? '₦';
    final interval = plan.interval ?? 'month';
    return '$currency ${plan.price}/$interval';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _errorBox({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB42318)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB42318),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB42318),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Try again'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalizeExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
