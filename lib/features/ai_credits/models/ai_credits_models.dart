class AiCreditsBalance {
  const AiCreditsBalance({
    required this.availableCredits,
    required this.isUnlimited,
    this.usedCredits,
    this.totalCredits,
    this.message = '',
  });

  final int? availableCredits;
  final bool isUnlimited;
  final int? usedCredits;
  final int? totalCredits;
  final String message;

  String get displayValue {
    if (isUnlimited) {
      return 'Unlimited';
    }
    if (availableCredits == null) {
      return '--';
    }
    return availableCredits.toString();
  }

  String get summaryText {
    if (isUnlimited) {
      return 'Your AI advisory credits are unlimited on this plan.';
    }
    if (availableCredits == null) {
      return message.isNotEmpty
          ? message
          : 'AI advisory credit balance is unavailable right now.';
    }
    if (availableCredits == 1) {
      return 'You have 1 AI advisory credit available.';
    }
    return 'You have $availableCredits AI advisory credits available.';
  }

  factory AiCreditsBalance.fromJson(Map<String, dynamic> json) {
    final message = json['message']?.toString() ?? '';
    final data = json['data'];

    final candidateMaps = <Map<String, dynamic>>[
      json,
      if (data is Map<String, dynamic>) data,
      if (data is Map) Map<String, dynamic>.from(data),
      if (data is Map && data['balance'] is Map<String, dynamic>)
        data['balance'] as Map<String, dynamic>,
      if (data is Map && data['credits'] is Map<String, dynamic>)
        data['credits'] as Map<String, dynamic>,
    ];

    final directNumericValue = _parseInt(data);
    final availableCredits =
        directNumericValue ??
        _firstInt([
          for (final candidate in candidateMaps) ...[
            candidate['available_credits'],
            candidate['availableCredits'],
            candidate['remaining_credits'],
            candidate['remainingCredits'],
            candidate['credits'],
            candidate['credit_balance'],
            candidate['creditBalance'],
            candidate['balance'],
            candidate['ai_credits'],
            candidate['aiCredits'],
          ],
        ]);

    final usedCredits = _firstInt([
      for (final candidate in candidateMaps) ...[
        candidate['used_credits'],
        candidate['usedCredits'],
        candidate['consumed_credits'],
        candidate['consumedCredits'],
        candidate['spent_credits'],
        candidate['spentCredits'],
      ],
    ]);

    final totalCredits = _firstInt([
      for (final candidate in candidateMaps) ...[
        candidate['total_credits'],
        candidate['totalCredits'],
      ],
    ]);

    final isUnlimited =
        _firstBool([
          for (final candidate in candidateMaps) ...[
            candidate['is_unlimited'],
            candidate['isUnlimited'],
            candidate['unlimited'],
          ],
        ]) ??
        false;

    return AiCreditsBalance(
      availableCredits: availableCredits,
      isUnlimited: isUnlimited,
      usedCredits: usedCredits,
      totalCredits: totalCredits,
      message: message,
    );
  }

  static int? _firstInt(List<dynamic> values) {
    for (final value in values) {
      final parsed = _parseInt(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return int.tryParse(text);
  }

  static bool? _firstBool(List<dynamic> values) {
    for (final value in values) {
      if (value is bool) {
        return value;
      }

      final text = value?.toString().trim().toLowerCase();
      if (text == 'true' || text == '1') {
        return true;
      }
      if (text == 'false' || text == '0') {
        return false;
      }
    }
    return null;
  }
}
