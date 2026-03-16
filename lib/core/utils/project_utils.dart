import 'package:intl/intl.dart';
import 'package:converf/features/projects/models/project.dart';

extension ProjectFormatting on Project {
  String get formattedLocation {
    final parts = [city, state, country].where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Location pending';
    
    // e.g. "Lekki Phase 1, Lagos"
    if (parts.length >= 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return parts.join(', ');
  }

  String get formattedBudget {
    final currencySymbol = currency == 'NGN' ? '₦' : '\$';
    
    // Parse the string 'budget' to a double
    final parsedBudget = double.tryParse(budget.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    
    final fullFormat = NumberFormat('#,##0');
    return '$currencySymbol${fullFormat.format(parsedBudget)}';
  }

  String get formattedDuration {
    if (startDate.isEmpty || endDate.isEmpty) return 'Unknown duration';
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final diff = end.difference(start);
      final months = (diff.inDays / 30).round();
      if (months >= 1) {
        return '$months month${months > 1 ? 's' : ''}';
      }
      return '${diff.inDays} days';
    } catch (_) {
      return 'Unknown duration';
    }
  }

  String get formattedStartDate {
    if (startDate.isEmpty) return 'TBD';
    try {
      final date = DateTime.parse(startDate);
      return DateFormat('MMM yyyy').format(date); 
    } catch (_) {
      return startDate;
    }
  }

  String get daysRemaining {
    if (endDate.isEmpty) return '--';
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      
      if (now.isAfter(end)) return '0';
      
      final diff = end.difference(now);
      return diff.inDays.toString();
    } catch (_) {
      return '--';
    }
  }
}

extension ProjectFinancialsFormatting on ProjectFinancials {
  String get formattedContractValue {
    final symbol = currency == 'NGN' ? '₦' : '\$';
    final format = NumberFormat.compact(); 
    return '$symbol${format.format(totalContractValue)}';
  }

  String get formattedEarnedValue {
    final symbol = currency == 'NGN' ? '₦' : '\$';
    final format = NumberFormat('#,##0');
    return '$symbol${format.format(totalEarned)}';
  }

  int get budgetUtilizedPercentage {
    if (totalContractValue <= 0) return 0;
    return ((totalEarned / totalContractValue) * 100).round().clamp(0, 100);
  }
}
