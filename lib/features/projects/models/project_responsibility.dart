// Model matching the web app's ProjectResponsibilitySummary type
// API endpoint: GET /api/v1/projects/{id}/responsibility

class ResponsibilityCurrentHolder {
  final String id;
  final String firstName;
  final String lastName;
  final String role;

  ResponsibilityCurrentHolder({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory ResponsibilityCurrentHolder.fromJson(Map<String, dynamic> json) {
    return ResponsibilityCurrentHolder(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  String get displayName => '$firstName $lastName'.trim();
}

class ResponsibilityFocusItem {
  final String type;
  final String id;
  final String? updatedAt;

  ResponsibilityFocusItem({
    required this.type,
    required this.id,
    this.updatedAt,
  });

  factory ResponsibilityFocusItem.fromJson(Map<String, dynamic> json) {
    return ResponsibilityFocusItem(
      type: json['type']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class ProjectResponsibilitySummary {
  final int totalOpenItems;
  final int itemsForYou;
  final bool hasItemsForYou;
  final bool actionRequiredNow;
  final ResponsibilityCurrentHolder? currentHolder;
  final ResponsibilityFocusItem? focusItem;

  ProjectResponsibilitySummary({
    required this.totalOpenItems,
    required this.itemsForYou,
    required this.hasItemsForYou,
    required this.actionRequiredNow,
    this.currentHolder,
    this.focusItem,
  });

  factory ProjectResponsibilitySummary.fromJson(Map<String, dynamic> json) {
    return ProjectResponsibilitySummary(
      totalOpenItems: json['total_open_items'] as int? ?? 0,
      itemsForYou: json['items_for_you'] as int? ?? 0,
      hasItemsForYou: json['has_items_for_you'] as bool? ?? false,
      actionRequiredNow: json['action_required_now'] as bool? ?? false,
      currentHolder: json['current_holder'] is Map<String, dynamic>
          ? ResponsibilityCurrentHolder.fromJson(
              json['current_holder'] as Map<String, dynamic>)
          : null,
      focusItem: json['focus_item'] is Map<String, dynamic>
          ? ResponsibilityFocusItem.fromJson(
              json['focus_item'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The label shown in the ball-in-court card (mirrors web app responsibility-utils.ts)
  String get assigneeLabel {
    final holder = currentHolder;
    if (holder != null && holder.displayName.isNotEmpty) {
      return hasItemsForYou
          ? '${holder.displayName} (You)'
          : holder.displayName;
    }
    if (totalOpenItems > 0) return 'Awaiting Assignment';
    return 'All Clear';
  }

  /// Action text shown below the assignee (mirrors web app responsibility-utils.ts)
  String get actionText {
    final focus = focusItem;
    if (focus == null) return 'No immediate action required';
    return 'Follow up on ${focus.type}';
  }

  /// Card status — drives styling (pending = orange, approved = green)
  String get cardStatus => totalOpenItems > 0 ? 'pending' : 'approved';
}

class ProjectResponsibilityResponse {
  final bool status;
  final String message;
  final ProjectResponsibilitySummary? data;

  ProjectResponsibilityResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProjectResponsibilityResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponsibilityResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ProjectResponsibilitySummary.fromJson(
              json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
