import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/providers/project_providers.dart';
import 'package:converf/features/projects/providers/schedule_providers.dart';
import 'package:converf/features/projects/providers/milestone_providers.dart';
import 'package:converf/features/projects/models/milestone.dart';
import 'package:intl/intl.dart';

class OverviewModal extends ConsumerWidget {
  final String projectId;
  const OverviewModal({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    final scheduleAsync = ref.watch(projectScheduleProvider(projectId));
    final milestonesAsync = ref.watch(projectMilestonesProvider(projectId));

    // Use any cached project data while a refresh is in flight to avoid blank spinners.
    var project = projectAsync.asData?.value.data;
    projectAsync.when(
      data: (response) => project = response.data,
      loading: () {
        // keep cached project if available
      },
      error: (_, errIgnored) {
        // keep cached project if available
      },
    );

    return _buildOverviewContainer(
      context,
      project,
      scheduleAsync,
      milestonesAsync,
    );
  }

  Widget _buildOverviewContainer(
    BuildContext context,
    dynamic project,
    AsyncValue<dynamic> scheduleAsync,
    AsyncValue<List<ProjectMilestone>> milestonesAsync,
  ) {
    if (project == null) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF276572)),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildProjectSection(project),
              const SizedBox(height: 24),
              _buildScheduleSection(scheduleAsync),
              const SizedBox(height: 24),
              _buildMilestoneSection(milestonesAsync),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/home-2.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF276572),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectSection(dynamic project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          project.description,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF475467),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Project Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        const Divider(height: 24, color: Color(0xFFEAECF0)),
        _buildDetailRow(
          'Project Owner',
          project.owner?.displayName ?? 'Not Assigned',
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          'Start Date',
          project.formattedDates.split(' - ').first,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          'Expected Completion',
          project.formattedDates.split(' - ').last,
        ),
        const SizedBox(height: 16),
        _buildDetailRow('Location', project.formattedLocation),
      ],
    );
  }

  Widget _buildScheduleSection(AsyncValue<dynamic> scheduleAsync) {
    return scheduleAsync.when(
      skipLoadingOnRefresh: true,
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: Color(0xFF276572)),
        ),
      ),
      error: (error, _) {
        final errStr = error.toString().toLowerCase();
        bool isNotFound =
            errStr.contains('404') ||
            errStr.contains('not found') ||
            errStr.contains('no query results');
        return _buildEmptySchedule(
          isNotFound
              ? 'No schedule has been created yet'
              : 'Schedule not available',
        );
      },
      data: (schedule) {
        if (schedule == null || schedule.phases.isEmpty) {
          return _buildEmptySchedule('No schedule has been created yet');
        }
        final currentPhase = schedule.phases.first.name;
        final completedCount = schedule.phases
            .where((p) => p.status == 'completed')
            .length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const Divider(height: 24, color: Color(0xFFEAECF0)),
            _buildDetailRow('Current Phase', currentPhase),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Phases Completed',
              '$completedCount of ${schedule.phases.length}',
            ),
            const SizedBox(height: 16),
            _buildDetailRowStatus('Schedule Status', schedule.statusLabel),
          ],
        );
      },
    );
  }

  Widget _buildEmptySchedule(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF667085),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowStatus(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 12.3,
              height: 17.5 / 12.3,
              color: Color(0xFFEA580C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneSection(
    AsyncValue<List<ProjectMilestone>> milestonesAsync,
  ) {
    return milestonesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF276572)),
      ),
      error: (error, _) => const SizedBox(),
      data: (milestones) {
        if (milestones.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Milestones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const Divider(height: 24, color: Color(0xFFEAECF0)),
            ...milestones.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101828),
                            ),
                          ),
                          if (m.dueDate != null)
                            Text(
                              'Due: ${DateFormat('MMM dd, yyyy').format(m.dueDate!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667085),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildMilestoneStatusBadge(m.status),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMilestoneStatusBadge(String status) {
    Color bg = const Color(0xFFF2F4F7);
    Color text = const Color(0xFF344054);

    switch (status.toLowerCase()) {
      case 'approved':
        bg = const Color(0xFFECFDF3);
        text = const Color(0xFF027A48);
        break;
      case 'pending':
        bg = const Color(0xFFFFFAEB);
        text = const Color(0xFFB54708);
        break;
      case 'declined':
        bg = const Color(0xFFFEF3F2);
        text = const Color(0xFFB42318);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
