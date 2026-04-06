class Invoice {
  final String id;
  final String projectId;
  final String? phaseId;
  final double amount;
  final String currency;
  final String? description;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.projectId,
    this.phaseId,
    required this.amount,
    required this.currency,
    this.description,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      projectId: json['project_id'] ?? '',
      phaseId: json['phase_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'NGN',
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class PaginatedInvoices {
  final List<Invoice> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedInvoices({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory PaginatedInvoices.fromJson(Map<String, dynamic> json) {
    var items = <Invoice>[];
    if (json['data'] != null) {
      if (json['data'] is List) {
        items = (json['data'] as List).map((i) => Invoice.fromJson(i)).toList();
      } else if (json['data']['data'] is List) {
        items = (json['data']['data'] as List).map((i) => Invoice.fromJson(i)).toList();
      }
    }
    
    final meta = json['meta'] ?? json['data'] ?? {};
    
    return PaginatedInvoices(
      data: items,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      total: meta['total'] ?? items.length,
      perPage: meta['per_page'] ?? items.length,
    );
  }
}
