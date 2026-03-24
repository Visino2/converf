class TemplatePhase {
  final String id;
  final int phaseNumber;
  final String name;
  final String slug;
  final int totalActivities;
  final String? parallelNotes;

  TemplatePhase({
    required this.id,
    required this.phaseNumber,
    required this.name,
    required this.slug,
    this.totalActivities = 0,
    this.parallelNotes,
  });

  factory TemplatePhase.fromJson(Map<String, dynamic> json) {
    return TemplatePhase(
      id: json['id']?.toString() ?? '',
      phaseNumber: json['phase_number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      totalActivities: json['total_activities'] as int? ?? 0,
      parallelNotes: json['parallel_notes'] as String?,
    );
  }
}

class TemplateActivity {
  final String id;
  final String phaseId;
  final String activityCode;
  final String description;
  final int standardDurationDays;
  final String? typicalPredecessors;
  final bool isMilestone;
  final bool canRunParallel;
  final int sortOrder;
  final bool isActive;

  TemplateActivity({
    required this.id,
    required this.phaseId,
    required this.activityCode,
    required this.description,
    this.standardDurationDays = 0,
    this.typicalPredecessors,
    this.isMilestone = false,
    this.canRunParallel = false,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory TemplateActivity.fromJson(Map<String, dynamic> json) {
    return TemplateActivity(
      id: json['id']?.toString() ?? '',
      phaseId: json['phase_id']?.toString() ?? '',
      activityCode: json['activity_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      standardDurationDays: json['standard_duration_days'] as int? ?? 0,
      typicalPredecessors: json['typical_predecessors'] as String?,
      isMilestone: json['is_milestone'] as bool? ?? false,
      canRunParallel: json['can_run_parallel'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class TemplateMilestone {
  final String id;
  final String activityId;
  final String milestoneName;
  final String activityCode;
  final String? responsibleParty;
  final int sortOrder;
  final TemplateActivity? activity;

  TemplateMilestone({
    required this.id,
    required this.activityId,
    required this.milestoneName,
    required this.activityCode,
    this.responsibleParty,
    this.sortOrder = 0,
    this.activity,
  });

  factory TemplateMilestone.fromJson(Map<String, dynamic> json) {
    return TemplateMilestone(
      id: json['id']?.toString() ?? '',
      activityId: json['activity_id']?.toString() ?? '',
      milestoneName: json['milestone_name'] as String? ?? '',
      activityCode: json['activity_code'] as String? ?? '',
      responsibleParty: json['responsible_party'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      activity: json['activity'] != null
          ? TemplateActivity.fromJson(json['activity'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ParallelGroup {
  final String id;
  final String groupName;
  final List<String> activityCodes;
  final String? description;
  final int sortOrder;

  ParallelGroup({
    required this.id,
    required this.groupName,
    required this.activityCodes,
    this.description,
    this.sortOrder = 0,
  });

  factory ParallelGroup.fromJson(Map<String, dynamic> json) {
    return ParallelGroup(
      id: json['id']?.toString() ?? '',
      groupName: json['group_name'] as String? ?? '',
      activityCodes: (json['activity_codes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
