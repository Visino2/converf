import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../models/schedule.dart';
import 'project_providers.dart';
import 'schedule_providers.dart';
import 'project_team_providers.dart';

class ProjectSummary {
  final Project? project;
  final List<SchedulePhase> phases;
  final ProjectFinancials? financials;
  final int teamSize;

  ProjectSummary({
    this.project,
    this.phases = const [],
    this.financials,
    this.teamSize = 0,
  });

  int get progressValue {
    if (phases.isEmpty) return 0;
    final completed = phases
        .where((p) => p.status?.toLowerCase() == 'completed')
        .length;
    return ((completed / phases.length) * 100).round();
  }

  int get budgetUtilized {
    final financials = this.financials;
    final contractValue = financials?.totalContractValue ?? 0;

    if (financials == null || contractValue <= 0) {
      return 0;
    }

    return ((financials.totalEarned / contractValue) * 100).round();
  }

  bool get isLoading => project == null;
}

final projectSummaryProvider = FutureProvider.family<ProjectSummary, String>((
  ref,
  projectId,
) async {
  final projectAsync = ref.watch(projectDetailsProvider(projectId));
  final financialsAsync = ref.watch(projectFinancialsProvider(projectId));
  final teamAsync = ref.watch(projectTeamProvider(projectId));

  // To get phases, we need the scheduleId first
  final scheduleAsync = ref.watch(projectScheduleProvider(projectId));

  final project = projectAsync.value?.data;
  final financials = financialsAsync.value;
  final teamMembers = teamAsync.value ?? [];

  List<SchedulePhase> phases = [];
  if (scheduleAsync.hasValue) {
    final scheduleId = scheduleAsync.value!.id;
    final phasesAsync = ref.watch(schedulePhasesProvider(scheduleId));
    phases = phasesAsync.value ?? [];
  }

  return ProjectSummary(
    project: project,
    phases: phases,
    financials: financials,
    teamSize: teamMembers.length + 1, // +1 for owner
  );
});
