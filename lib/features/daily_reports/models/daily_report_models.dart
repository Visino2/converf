import '../../projects/models/project_image.dart';

enum DailyReportStatus {
  draft,
  submitted,
  reviewed;

  static DailyReportStatus fromString(String status) {
    return DailyReportStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => DailyReportStatus.draft,
    );
  }
}

class DailyReportActivityUpdate {
  final String id;
  final String projectActivityId;
  final String? plannedPct;
  final String actualPct;
  final String status;
  final bool isCritical;

  DailyReportActivityUpdate({
    required this.id,
    required this.projectActivityId,
    this.plannedPct,
    required this.actualPct,
    required this.status,
    this.isCritical = false,
  });

  factory DailyReportActivityUpdate.fromJson(Map<String, dynamic> json) {
    return DailyReportActivityUpdate(
      id: json['id']?.toString() ?? '',
      projectActivityId: json['project_activity_id']?.toString() ?? '',
      plannedPct: json['planned_pct']?.toString(),
      actualPct: json['actual_pct']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      isCritical: json['is_critical'] == true,
    );
  }
}

class DailyReportIssue {
  final String id;
  final String issueType;
  final String impactDays;
  final String? resolutionType;
  final String? resolutionNote;
  final String? assignedTo;

  DailyReportIssue({
    required this.id,
    required this.issueType,
    required this.impactDays,
    this.resolutionType,
    this.resolutionNote,
    this.assignedTo,
  });

  factory DailyReportIssue.fromJson(Map<String, dynamic> json) {
    return DailyReportIssue(
      id: json['id']?.toString() ?? '',
      issueType: json['issue_type']?.toString() ?? '',
      impactDays: json['impact_days']?.toString() ?? '0',
      resolutionType: json['resolution_type']?.toString(),
      resolutionNote: json['resolution_note']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
    );
  }
}

class DailyReport {
  final String id;
  final String projectId;
  final String reportDate;
  final int? projectDay;
  final DailyReportStatus status;
  final String? weatherCondition;
  final String? temperatureC;
  final bool? siteAccessible;
  final bool? weatherStoppage;
  final String? weatherHoursLost;
  final String? concretePourPossible;
  final int? laborCount;
  final String? laborSufficiency;
  final int? equipmentOperatingCount;
  final bool? equipmentDown;
  final int? deliveriesCount;
  final bool? materialShortage;
  final List<DailyReportActivityUpdate> activityUpdates;
  final List<DailyReportIssue> issues;
  final List<DailyReportActivityUpdate> tomorrowPlan;
  final List<ProjectImage> linkedPhotos;

  DailyReport({
    required this.id,
    required this.projectId,
    required this.reportDate,
    this.projectDay,
    required this.status,
    this.weatherCondition,
    this.temperatureC,
    this.siteAccessible,
    this.weatherStoppage,
    this.weatherHoursLost,
    this.concretePourPossible,
    this.laborCount,
    this.laborSufficiency,
    this.equipmentOperatingCount,
    this.equipmentDown,
    this.deliveriesCount,
    this.materialShortage,
    this.activityUpdates = const [],
    this.issues = const [],
    this.tomorrowPlan = const [],
    this.linkedPhotos = const [],
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      reportDate: json['report_date']?.toString() ?? '',
      projectDay: json['project_day'] as int?,
      status: DailyReportStatus.fromString(json['status']?.toString() ?? ''),
      weatherCondition: json['weather_condition']?.toString(),
      temperatureC: json['temperature_c']?.toString(),
      siteAccessible: json['site_accessible'] as bool?,
      weatherStoppage: json['weather_stoppage'] as bool?,
      weatherHoursLost: json['weather_hours_lost']?.toString(),
      concretePourPossible: json['concrete_pour_possible']?.toString(),
      laborCount: json['labor_count'] as int?,
      laborSufficiency: json['labor_sufficiency']?.toString(),
      equipmentOperatingCount: json['equipment_operating_count'] as int?,
      equipmentDown: json['equipment_down'] as bool?,
      deliveriesCount: json['deliveries_count'] as int?,
      materialShortage: json['material_shortage'] as bool?,
      activityUpdates: (json['activity_updates'] as List?)
          ?.map((e) => DailyReportActivityUpdate.fromJson(e))
          .toList() ?? const [],
      issues: (json['issues'] as List?)
          ?.map((e) => DailyReportIssue.fromJson(e))
          .toList() ?? const [],
      tomorrowPlan: (json['tomorrow_plan'] as List?)
          ?.map((e) => DailyReportActivityUpdate.fromJson(e))
          .toList() ?? const [],
      linkedPhotos: (json['linked_photos'] as List?)
          ?.map((e) => ProjectImage.fromJson(e))
          .toList() ?? const [],
    );
  }
}

class DailyReportDraftPayload {
  final String reportDate;
  final Map<String, dynamic>? weather;
  final Map<String, dynamic>? resources;
  final List<Map<String, dynamic>>? activityUpdates;
  final List<Map<String, dynamic>>? issues;
  final List<Map<String, dynamic>>? tomorrowPlan;
  final bool? siteAccessible;
  final bool? weatherStoppage;
  final List<String>? linkedPhotoIds;
  final List<String>? linkedFieldInspectionIds;

  DailyReportDraftPayload({
    required this.reportDate,
    this.weather,
    this.resources,
    this.activityUpdates,
    this.issues,
    this.tomorrowPlan,
    this.siteAccessible,
    this.weatherStoppage,
    this.linkedPhotoIds,
    this.linkedFieldInspectionIds,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'report_date': reportDate,
    };

    if (weather != null) {
      data['weather'] = {
        ...weather!,
        if (weather!['temperature_c'] != null) 'temperature_c': double.tryParse(weather!['temperature_c'].toString()),
        if (weather!['weather_hours_lost'] != null) 'weather_hours_lost': double.tryParse(weather!['weather_hours_lost'].toString()),
      };
    }

    if (resources != null) data['resources'] = resources;
    if (activityUpdates != null) data['activity_updates'] = activityUpdates;
    
    if (issues != null) {
      data['issues'] = issues!.map((i) {
        final issue = Map<String, dynamic>.from(i);
        if (issue['resolution_type'] == '') issue['resolution_type'] = null;
        if (issue['assigned_to'] == '') issue['assigned_to'] = null;
        return issue;
      }).toList();
    }

    if (tomorrowPlan != null) {
      data['tomorrow_plan'] = tomorrowPlan!.map((p) {
        final plan = Map<String, dynamic>.from(p);
        if (plan['start_time'] != null && plan['start_time'].toString().length == 5) {
          plan['start_time'] = '${plan['start_time']}:00';
        }
        return plan;
      }).toList();
    }

    if (siteAccessible != null) data['site_accessible'] = siteAccessible;
    if (weatherStoppage != null) data['weather_stoppage'] = weatherStoppage;
    if (linkedPhotoIds != null) data['linked_photo_ids'] = linkedPhotoIds;
    if (linkedFieldInspectionIds != null) data['linked_field_inspection_ids'] = linkedFieldInspectionIds;

    return data;
  }
}

class DailyReportSectionUpdatePayload {
  final String section;
  final Map<String, dynamic> payload;

  DailyReportSectionUpdatePayload({
    required this.section,
    required this.payload,
  });

  Map<String, dynamic> toJson() => {
    'section': section,
    'payload': payload,
  };
}

class DailyReportFilters {
  final String? from;
  final String? to;
  final String? status;
  final int? page;
  final int? perPage;

  DailyReportFilters({this.from, this.to, this.status, this.page = 1, this.perPage = 15});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (from != null) map['from'] = from;
    if (to != null) map['to'] = to;
    if (status != null) map['status'] = status;
    if (page != null) map['page'] = page;
    if (perPage != null) map['per_page'] = perPage;
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyReportFilters &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          status == other.status &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(from, to, status, page, perPage);
}

class DailyReportsResponse {
  final bool status;
  final String message;
  final List<DailyReport> data;

  DailyReportsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DailyReportsResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataField = json['data'];
    List<dynamic> dataList = [];

    if (dataField is List<dynamic>) {
      dataList = dataField;
    } else if (dataField is Map<String, dynamic>) {
      // Handle nested data field in paginated responses
      if (dataField.containsKey('data')) {
        dataList = dataField['data'] as List<dynamic>? ?? [];
      }
    }

    return DailyReportsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataList.map((e) => DailyReport.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class DailyReportFormMeta {
  final String reportDate;
  final Map<String, dynamic> project;
  final Map<String, dynamic> defaults;
  final List<dynamic> todayCriticalActivities;
  final List<dynamic> tomorrowCriticalActivities;
  final List<dynamic> issueAssignees;
  final Map<String, dynamic> options;

  DailyReportFormMeta({
    required this.reportDate,
    required this.project,
    required this.defaults,
    this.todayCriticalActivities = const [],
    this.tomorrowCriticalActivities = const [],
    this.issueAssignees = const [],
    this.options = const {},
  });

  factory DailyReportFormMeta.fromJson(Map<String, dynamic> json) {
    return DailyReportFormMeta(
      reportDate: json['report_date']?.toString() ?? '',
      project: json['project'] as Map<String, dynamic>? ?? {},
      defaults: json['defaults'] as Map<String, dynamic>? ?? {},
      todayCriticalActivities: json['today_critical_activities'] as List? ?? [],
      tomorrowCriticalActivities: json['tomorrow_critical_activities'] as List? ?? [],
      issueAssignees: json['issue_assignees'] as List? ?? [],
      options: json['options'] as Map<String, dynamic>? ?? {},
    );
  }
}
