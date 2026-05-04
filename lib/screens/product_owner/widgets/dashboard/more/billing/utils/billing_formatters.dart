import 'package:converf/features/billing/models/billing_models.dart';
import 'package:intl/intl.dart';

String priceText(BillingPlan plan) {
  if (plan.price == null || plan.price == 0) {
    if (plan.name.toLowerCase().contains('enterprise')) {
      return 'Contact sales for custom pricing';
    }
    return 'Free';
  }
  final currency = plan.currency ?? '₦';
  final interval = plan.interval ?? 'month';
  final num price = plan.price as num;
  final formattedPrice = price == price.truncate()
      ? NumberFormat('#,###', 'en_US').format(price.toInt())
      : NumberFormat('#,##0.##', 'en_US').format(price);
  return '$currency$formattedPrice/$interval';
}

String formatFeatureName(String key) => key.replaceAll('_', ' ').toTitleCase();

String formatDate(DateTime? date) {
  if (date == null) return '—';
  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
