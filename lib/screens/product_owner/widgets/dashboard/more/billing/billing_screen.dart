import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:converf/features/ai_credits/providers/ai_credits_provider.dart';
import 'package:converf/features/auth/providers/auth_provider.dart';
import 'package:converf/features/billing/models/billing_models.dart';
import 'package:converf/features/billing/providers/billing_providers.dart';
import 'widgets/add_ons_section.dart';
import 'widgets/ai_credits_section.dart';
import 'widgets/payment_webview.dart';
import 'widgets/pending_verification_banner.dart';
import 'widgets/plans_section.dart';
import 'widgets/subscription_card_section.dart';
import 'widgets/transactions_section.dart';
import 'widgets/usage_section.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen>
    with WidgetsBindingObserver {
  int _txnPage = 1;

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
      _refreshPendingPaymentState();
    }
  }

  void _refreshPendingPaymentState() {
    final pendingRef = ref.read(pendingPaymentReferenceProvider);
    if (pendingRef != null) {
      _refreshBillingData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiCreditsState = ref.watch(aiCreditsProvider);
    final subscriptionState = ref.watch(billingSubscriptionProvider);
    final plansState = ref.watch(billingPlansProvider);
    final transactionsState = ref.watch(billingTransactionsProvider(_txnPage));
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
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
            AiCreditsSection(
              state: aiCreditsState,
              onRetry: () => ref.invalidate(aiCreditsProvider),
            ),
            const SizedBox(height: 24),
            SubscriptionCardSection(
              subscriptionState: subscriptionState,
              plansState: plansState,
              actionState: actionState,
              onStartPlan: _startSubscription,
              onCancel: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref.read(billingActionProvider.notifier).cancel();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Subscription cancelled')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Cancel failed: $e')),
                  );
                }
              },
              onRetry: () => ref.invalidate(billingSubscriptionProvider),
            ),
            const SizedBox(height: 24),
            if (subData?.limits != null) ...[
              UsageSection(limits: subData!.limits!),
              const SizedBox(height: 24),
            ],
            if (pendingRef != null) ...[
              PendingVerificationBanner(
                reference: pendingRef,
                actionState: actionState,
                onVerify: () =>
                    ref.read(billingActionProvider.notifier).verify(pendingRef),
              ),
              const SizedBox(height: 24),
            ],
            PlansSection(
              plansState: plansState,
              currentSubscription: subData,
              actionState: actionState,
              onSelectPlan: _startSubscription,
              onRetry: () => ref.invalidate(billingPlansProvider),
            ),
            const SizedBox(height: 32),
            AddOnsSection(
              plansState: plansState,
              actionState: actionState,
              onPurchase: (category, key) {
                final notifier = ref.read(billingActionProvider.notifier);
                if (category == 'storage') return notifier.buyStorage(key);
                if (category == 'team_seats') return notifier.buySeats(key);
                return notifier.buyAiCredits(key);
              },
              onPendingReference: (reference) => ref
                  .read(pendingPaymentReferenceProvider.notifier)
                  .setReference(reference),
              onLaunchPayment: _launchPayment,
            ),
            const SizedBox(height: 32),
            TransactionsSection(
              state: transactionsState,
              currentPage: _txnPage,
              onRetry: () =>
                  ref.invalidate(billingTransactionsProvider(_txnPage)),
              onPageChanged: (page) => setState(() => _txnPage = page),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSubscription(String planId) async {
    try {
      final intent = await ref
          .read(billingActionProvider.notifier)
          .subscribe(planId);

      if (intent.requiresPayment) {
        ref
            .read(pendingPaymentReferenceProvider.notifier)
            .setReference(intent.reference);
        if (!mounted) return;
        await _launchPayment(intent.paymentUrl);
        return;
      }

      if (!mounted) return;
      await _completePlanChange(intent);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Subscription failed: $e')));
    }
  }

  Future<void> _completePlanChange(PaymentIntent intent) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (intent.hasReference) {
        ref
            .read(pendingPaymentReferenceProvider.notifier)
            .setReference(intent.reference);
        await ref.read(billingActionProvider.notifier).verify(intent.reference);
      } else {
        ref.read(pendingPaymentReferenceProvider.notifier).clear();
        await _refreshBillingData();
      }

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            intent.message?.trim().isNotEmpty == true
                ? intent.message!
                : 'Plan updated successfully.',
          ),
          backgroundColor: const Color(0xFF0F973D),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Plan update failed: $e'),
          backgroundColor: const Color(0xFFD92D20),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _launchPayment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open payment link')),
      );
      return;
    }

    final pendingReference = ref.read(pendingPaymentReferenceProvider);
    debugPrint(
      '[Billing] launching payment webview for '
      '${pendingReference ?? 'no-reference'} -> $url',
    );

    if (!mounted) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            PaymentWebView(initialUrl: uri, reference: pendingReference),
        fullscreenDialog: true,
      ),
    );

    if (!mounted) return;

    debugPrint('[Billing] payment webview closed with result=$result');

    final messenger = ScaffoldMessenger.of(context);

    // If payment was successful, verify and update plan
    if (result == true) {
      try {
        final pendingRef = ref.read(pendingPaymentReferenceProvider);

        if (pendingRef != null) {
          await ref.read(billingActionProvider.notifier).verify(pendingRef);
        } else {
          await _refreshBillingData();
        }

        await _refreshBillingData();

        messenger.showSnackBar(
          const SnackBar(
            content: Text('✓ Payment completed successfully! Plan updated.'),
            backgroundColor: Color(0xFF0F973D),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (_) {
        await _refreshBillingData();
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Payment received. Your plan has been updated.'),
            backgroundColor: Color(0xFF0F973D),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else if (result == false) {
      // Payment failed or was cancelled
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Payment cancelled or failed. Please try again.'),
          backgroundColor: Color(0xFFD92D20),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // User cancelled without result
      _refreshPendingPaymentState();
    }
  }

  Future<void> _refreshBillingData() async {
    ref.invalidate(billingSubscriptionProvider);
    ref.invalidate(billingTransactionsProvider);
    ref.invalidate(billingPlansProvider);
    ref.invalidate(aiCreditsProvider);

    await Future.wait<void>([
      ref.read(billingSubscriptionProvider.future).then((_) {}).catchError((_) {}),
      ref.read(authProvider.notifier).refreshUser().catchError((_) {}),
    ]);
  }

}

