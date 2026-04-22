class BillingTransaction {
  final String id;
  final num amount;
  final String? currency;
  final String? status;
  final String? reference;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  BillingTransaction({
    required this.id,
    required this.amount,
    this.currency,
    this.status,
    this.reference,
    this.createdAt,
    this.raw = const {},
  });

  factory BillingTransaction.fromJson(Map<String, dynamic> json) {
    final createdText = json['created_at']?.toString();
    return BillingTransaction(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?) ?? 0,
      currency: json['currency']?.toString(),
      status: json['status']?.toString(),
      reference: json['reference']?.toString(),
      createdAt: createdText != null ? DateTime.tryParse(createdText) : null,
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class BillingPlan {
  final String id;
  final String name;
  final String? displayName;
  final num? price;
  final String? currency;
  final String? interval;
  final Map<String, bool> features;
  final Map<String, dynamic> raw;

  BillingPlan({
    required this.id,
    required this.name,
    this.displayName,
    this.price,
    this.currency,
    this.interval,
    this.features = const {},
    this.raw = const {},
  });

  factory BillingPlan.fromJson(Map<String, dynamic> json) {
    final featuresMap = json['features'] as Map<String, dynamic>? ?? {};
    return BillingPlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      price: json['price'] as num? ?? (json['price_kobo'] as num? ?? 0) / 100,
      currency: json['currency']?.toString(),
      interval:
          json['billing_interval']?.toString() ?? json['interval']?.toString(),
      features: featuresMap.map((key, value) => MapEntry(key, value == true)),
      raw: Map<String, dynamic>.from(json),
    );
  }

  String get label => displayName ?? name;
}

class BillingLimits {
  final StorageLimit storage;
  final int? teamMembers;
  final int? maxProjects;
  final int? aiCredits;

  BillingLimits({
    required this.storage,
    this.teamMembers,
    this.maxProjects,
    this.aiCredits,
  });

  factory BillingLimits.fromJson(Map<String, dynamic> json) {
    return BillingLimits(
      storage: StorageLimit.fromJson(
        json['storage'] as Map<String, dynamic>? ?? {},
      ),
      teamMembers: json['team_members'] as int?,
      maxProjects: json['max_projects'] as int?,
      aiCredits: json['ai_credits'] as int?,
    );
  }
}

class StorageLimit {
  final double usedGb;
  final double allowedGb;
  final int usedBytes;
  final int allowedBytes;

  StorageLimit({
    required this.usedGb,
    required this.allowedGb,
    required this.usedBytes,
    required this.allowedBytes,
  });

  factory StorageLimit.fromJson(Map<String, dynamic> json) {
    return StorageLimit(
      usedGb: (json['used_gb'] as num? ?? 0).toDouble(),
      allowedGb: (json['allowed_gb'] as num? ?? 0).toDouble(),
      usedBytes: json['used_bytes'] as int? ?? 0,
      allowedBytes: json['allowed_bytes'] as int? ?? 0,
    );
  }

  double get usagePercentage =>
      allowedBytes > 0 ? (usedBytes / allowedBytes) : 0;
}

class BillingSubscription {
  final String? status;
  final String? planName;
  final String? planId;
  final DateTime? renewsAt;
  final BillingLimits? limits;
  final BillingPlan? plan;
  final Map<String, dynamic> raw;

  BillingSubscription({
    this.status,
    this.planName,
    this.planId,
    this.renewsAt,
    this.limits,
    this.plan,
    this.raw = const {},
  });

  factory BillingSubscription.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final renewsText = (root['renews_at'] ?? root['next_billing_date'])
        ?.toString();

    return BillingSubscription(
      status:
          root['subscription']?['status']?.toString() ??
          root['status']?.toString(),
      planName:
          root['plan']?['display_name']?.toString() ??
          root['plan']?['name']?.toString() ??
          root['plan_name']?.toString(),
      planId: root['plan']?['id']?.toString() ?? root['plan_id']?.toString(),
      renewsAt: (renewsText != null && renewsText.isNotEmpty)
          ? DateTime.tryParse(renewsText)
          : null,
      limits: root['limits'] != null
          ? BillingLimits.fromJson(root['limits'] as Map<String, dynamic>)
          : null,
      plan: root['plan'] != null
          ? BillingPlan.fromJson(root['plan'] as Map<String, dynamic>)
          : null,
      raw: root,
    );
  }
}

class AddonPack {
  final String label;
  final double price;
  final String? currency;

  AddonPack({required this.label, required this.price, this.currency});

  factory AddonPack.fromJson(Map<String, dynamic> json) {
    return AddonPack(
      label: json['label']?.toString() ?? '',
      price: (json['price_kobo'] as num? ?? 0) / 100,
      currency: json['currency']?.toString(),
    );
  }
}

class BillingPlansResponse {
  final List<BillingPlan> plans;
  final Map<String, Map<String, AddonPack>> addonPacks;

  BillingPlansResponse({required this.plans, required this.addonPacks});

  factory BillingPlansResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final plansList = (data['plans'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => BillingPlan.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final addonsMap = data['addon_packs'] as Map<String, dynamic>? ?? {};
    final parsedAddons = addonsMap.map((category, packs) {
      final categoryPacks = packs as Map<String, dynamic>? ?? {};
      return MapEntry(
        category,
        categoryPacks.map(
          (key, packData) => MapEntry(
            key,
            AddonPack.fromJson(packData as Map<String, dynamic>),
          ),
        ),
      );
    });

    return BillingPlansResponse(plans: plansList, addonPacks: parsedAddons);
  }
}

class PaymentIntent {
  final String paymentUrl;
  final String reference;
  final String? message;
  final bool? status;
  final Map<String, dynamic> raw;

  PaymentIntent({
    required this.paymentUrl,
    required this.reference,
    this.message,
    this.status,
    this.raw = const {},
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return PaymentIntent(
      paymentUrl:
          data['payment_url']?.toString() ??
          data['checkout_url']?.toString() ??
          data['authorization_url']?.toString() ??
          '',
      reference:
          data['reference']?.toString() ??
          data['payment_reference']?.toString() ??
          data['trxref']?.toString() ??
          '',
      message: data['message']?.toString() ?? json['message']?.toString(),
      status: data['status'] as bool? ?? json['status'] as bool?,
      raw: Map<String, dynamic>.from(data),
    );
  }

  bool get requiresPayment => paymentUrl.trim().isNotEmpty;

  bool get hasReference => reference.trim().isNotEmpty;
}

class PaginatedTransactions {
  final List<BillingTransaction> data;
  final Map<String, dynamic> meta;

  PaginatedTransactions({required this.data, this.meta = const {}});

  factory PaginatedTransactions.fromJson(Map<String, dynamic> json) {
    final envelope = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final items = envelope['data'] as List<dynamic>? ?? [];
    return PaginatedTransactions(
      data: items
          .whereType<Map>()
          .map((e) => BillingTransaction.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      meta: envelope['meta'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(envelope['meta'] as Map)
          : const {},
    );
  }
}
