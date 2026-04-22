import 'package:converf/features/billing/models/billing_models.dart';

String priceText(BillingPlan plan) {
  if (plan.price == null || plan.price == 0) {
    if (plan.name.toLowerCase().contains('enterprise')) {
      return 'Contact sales for custom pricing';
    }
    return 'Premium Plan';
  }
  final currency = plan.currency ?? '₦';
  final interval = plan.interval ?? 'month';
  final formattedPrice = (plan.price as num).toStringAsFixed(2);
  return '$currency $formattedPrice/$interval';
}

String formatFeatureName(String key) => key.replaceAll('_', ' ').toTitleCase();

String formatDate(DateTime? date) {
  if (date == null) return '—';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

extension StringCapitalizeExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
