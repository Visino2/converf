import 'project.dart';

class ScheduleActivity {
  final String id;
  final String? projectId;
  final String? phaseId;
  final String title;
  final String? deadline;
  final String? status;
  final double? budgetAmount;
  final bool isCompleted;
  final String? completedAt;
  final ProjectParty? assignedTo;
  final String? assignedRoleLabel;
  final String? activityCode;
  final int? standardDurationDays;
  final String? templatePredecessors;
  final bool canRunParallel;
  final bool isMilestone;
  final bool isImported;
  final String? createdAt;
  final String? updatedAt;

  ScheduleActivity({
    required this.id,
    this.projectId,
    this.phaseId,
    required this.title,
    this.deadline,
    this.status,
    this.budgetAmount,
    this.isCompleted = false,
    this.completedAt,
    this.assignedTo,
    this.assignedRoleLabel,
    this.activityCode,
    this.standardDurationDays,
    this.templatePredecessors,
    this.canRunParallel = false,
    this.isMilestone = false,
    this.isImported = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleActivity.fromJson(Map<String, dynamic> json) {
    return ScheduleActivity(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      phaseId: json['phase_id']?.toString(),
      title: json['title'] as String? ?? '',
      deadline: json['deadline'] as String?,
      status: json['status'] as String?,
      budgetAmount: (json['budget_amount'] as num?)?.toDouble(),
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] as String?,
      assignedTo: json['assigned_to'] != null
          ? ProjectParty.fromJson(json['assigned_to'] as Map<String, dynamic>)
          : null,
      assignedRoleLabel: json['assigned_role_label'] as String?,
      activityCode: json['activity_code'] as String?,
      standardDurationDays: json['standard_duration_days'] as int?,
      templatePredecessors: json['template_predecessors'] as String?,
      canRunParallel: json['can_run_parallel'] as bool? ?? false,
      isMilestone: json['is_milestone'] as bool? ?? false,
      isImported: json['is_imported'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (deadline != null) 'deadline': deadline,
      if (budgetAmount != null) 'budget_amount': budgetAmount,
      if (assignedTo != null) 'assigned_to': assignedTo?.id,
      if (assignedRoleLabel != null) 'assigned_role_label': assignedRoleLabel,
      'standard_duration_days': standardDurationDays,
      'can_run_parallel': canRunParallel,
      'is_milestone': isMilestone,
    };
  }
}

class SchedulePhase {
  final String id;
  final String? projectId;
  final String? scheduleId;
  final String? templatePhaseId;
  final String name;
  final String? startDate;
  final String? endDate;
  final String? status;
  final double? budgetAmount;
  final int order;
  final int activitiesCount;
  final List<ScheduleActivity> activities;
  final String? createdAt;

  SchedulePhase({
    required this.id,
    this.projectId,
    this.scheduleId,
    this.templatePhaseId,
    required this.name,
    this.startDate,
    this.endDate,
    this.status,
    this.budgetAmount,
    this.order = 0,
    this.activitiesCount = 0,
    this.activities = const [],
    this.createdAt,
  });

  factory SchedulePhase.fromJson(Map<String, dynamic> json) {
    return SchedulePhase(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      scheduleId: json['schedule_id']?.toString(),
      templatePhaseId: json['template_phase_id']?.toString(),
      name: json['name'] as String? ?? '',
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String?,
      budgetAmount: (json['budget_amount'] as num?)?.toDouble(),
      order: json['order'] as int? ?? 0,
      activitiesCount: json['activities_count'] as int? ?? 0,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => ScheduleActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order': order,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (budgetAmount != null) 'budget_amount': budgetAmount,
    };
  }
}

class ScheduleRevisionHistory {
  final String id;
  final String scheduleId;
  final ProjectParty? changedBy;
  final String fromStatus;
  final String toStatus;
  final String? notes;
  final String changedAt;

  ScheduleRevisionHistory({
    required this.id,
    required this.scheduleId,
    this.changedBy,
    required this.fromStatus,
    required this.toStatus,
    this.notes,
    required this.changedAt,
  });

  factory ScheduleRevisionHistory.fromJson(Map<String, dynamic> json) {
    return ScheduleRevisionHistory(
      id: json['id']?.toString() ?? '',
      scheduleId: json['schedule_id']?.toString() ?? '',
      changedBy: json['changed_by'] != null
          ? ProjectParty.fromJson(json['changed_by'] as Map<String, dynamic>)
          : null,
      fromStatus: json['from_status'] as String? ?? '',
      toStatus: json['to_status'] as String? ?? '',
      notes: json['notes'] as String?,
      changedAt: json['changed_at'] as String? ?? '',
    );
  }
}

class Schedule {
  final String id;
  final String projectId;
  final String status;
  final String statusLabel;
  final String contractorId;
  final ProjectParty? contractor;
  final String? bidId;
  final String? contractorNotes;
  final String? ownerFeedback;
  final String? submittedAt;
  final String? resubmittedAt;
  final String? approvedAt;
  final ProjectParty? approvedBy;
  final bool isLocked;
  final bool isEditable;
  final List<SchedulePhase> phases;
  final List<ScheduleRevisionHistory> revisionHistory;
  final String createdAt;
  final String updatedAt;

  Schedule({
    required this.id,
    required this.projectId,
    required this.status,
    required this.statusLabel,
    required this.contractorId,
    this.contractor,
    this.bidId,
    this.contractorNotes,
    this.ownerFeedback,
    this.submittedAt,
    this.resubmittedAt,
    this.approvedAt,
    this.approvedBy,
    required this.isLocked,
    required this.isEditable,
    this.phases = const [],
    this.revisionHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'draft',
      statusLabel: json['status_label'] as String? ?? 'Draft',
      contractorId: json['contractor_id']?.toString() ?? '',
      contractor: json['contractor'] != null
          ? ProjectParty.fromJson(json['contractor'] as Map<String, dynamic>)
          : null,
      bidId: json['bid_id']?.toString(),
      contractorNotes: json['contractor_notes'] as String?,
      ownerFeedback: json['owner_feedback'] as String?,
      submittedAt: json['submitted_at'] as String?,
      resubmittedAt: json['resubmitted_at'] as String?,
      approvedAt: json['approved_at'] as String?,
      approvedBy: json['approved_by'] != null
          ? ProjectParty.fromJson(json['approved_by'] as Map<String, dynamic>)
          : null,
      isLocked: json['is_locked'] as bool? ?? false,
      isEditable: json['is_editable'] as bool? ?? true,
      phases: (json['phases'] as List<dynamic>?)
              ?.map((e) => SchedulePhase.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      revisionHistory: (json['revision_history'] as List<dynamic>?)
              ?.map((e) => ScheduleRevisionHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class ScheduleImportSelection {
  final String phaseId;
  final List<String> activityIds;

  ScheduleImportSelection({
    required this.phaseId,
    required this.activityIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'activity_ids': activityIds,
    };
  }
}
