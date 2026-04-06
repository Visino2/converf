enum EmailVerificationStatus {
  verified,
  unverified,
  unknown;

  bool get isVerified => this == EmailVerificationStatus.verified;
  bool get isUnverified => this == EmailVerificationStatus.unverified;
  bool get isKnown => this != EmailVerificationStatus.unknown;
}

EmailVerificationStatus emailVerificationStatusFromPayload(
  Map<String, dynamic>? payload,
) {
  if (payload == null || payload.isEmpty) {
    return EmailVerificationStatus.unknown;
  }

  final candidates = <Map<String, dynamic>>[
    payload,
    if (payload['user'] is Map<String, dynamic>)
      Map<String, dynamic>.from(payload['user'] as Map<String, dynamic>),
    if (payload['data'] is Map<String, dynamic>)
      Map<String, dynamic>.from(payload['data'] as Map<String, dynamic>),
  ];

  for (final candidate in candidates) {
    final explicitVerifiedAt = _firstNonEmptyString([
      candidate['email_verified_at'],
      candidate['emailVerifiedAt'],
      candidate['verified_at'],
      candidate['verifiedAt'],
    ]);

    if (explicitVerifiedAt != null) {
      return EmailVerificationStatus.verified;
    }

    final explicitBool = _firstBool([
      candidate['email_verified'],
      candidate['emailVerified'],
      candidate['is_email_verified'],
      candidate['isEmailVerified'],
      candidate['is_verified'],
      candidate['isVerified'],
      candidate['verified'],
    ]);

    if (explicitBool != null) {
      return explicitBool
          ? EmailVerificationStatus.verified
          : EmailVerificationStatus.unverified;
    }

    final verificationStatus = _firstNonEmptyString([
      candidate['verification_status'],
      candidate['verificationStatus'],
      candidate['email_verification_status'],
      candidate['emailVerificationStatus'],
      if (candidate['profile'] is Map<String, dynamic>)
        (candidate['profile'] as Map<String, dynamic>)['verification_status'],
    ]);

    final derived = emailVerificationStatusFromMessage(verificationStatus);
    if (derived.isKnown) {
      return derived;
    }
  }

  // If we have no verification signal, we cannot assume unverified because
  // login payloads often omit this field. Return unknown to force an API check.
  return EmailVerificationStatus.unknown;
}

EmailVerificationStatus emailVerificationStatusFromMessage(String? message) {
  final normalized = message?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) {
    return EmailVerificationStatus.unknown;
  }

  if (normalized.contains('not verified') ||
      normalized.contains('unverified') ||
      normalized.contains('verify your email') ||
      normalized.contains('email verification required') ||
      normalized.contains('pending')) {
    return EmailVerificationStatus.unverified;
  }

  if (normalized.contains('verified') ||
      normalized.contains('already verified') ||
      normalized.contains('welcome to converf')) {
    return EmailVerificationStatus.verified;
  }

  return EmailVerificationStatus.unknown;
}

String? _firstNonEmptyString(List<dynamic> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }
  return null;
}

bool? _firstBool(List<dynamic> values) {
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
