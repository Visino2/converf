import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/providers/schedule_providers.dart';
import 'package:converf/features/projects/models/schedule.dart';
import 'package:intl/intl.dart';
import 'package:converf/features/auth/providers/auth_provider.dart';
import 'package:converf/features/auth/models/auth_response.dart';
import 'widgets/schedule_dialogs.dart';
import 'schedule_library_import_screen.dart';
import 'package:converf/core/api/api_client.dart';
import 'package:converf/features/projects/repositories/schedule_repository.dart';
import 'dart:async';

class _StatusStyle {
  final String label;
  final Color bg;
  final Color text;
  const _StatusStyle({
    required this.label,
    required this.bg,
    required this.text,
  });
}

const _statusStyles = <String, _StatusStyle>{
  'draft': _StatusStyle(
    label: 'Draft',
    bg: Color(0xFFF0F2F5),
    text: Color(0xFF475367),
  ),
  'submitted': _StatusStyle(
    label: 'Submitted',
    bg: Color(0xFFFEF6E7),
    text: Color(0xFF865503),
  ),
  'revision_requested': _StatusStyle(
    label: 'Revision Requested',
    bg: Color(0xFFFFF4ED),
    text: Color(0xFF9A3412),
  ),
  'resubmitted': _StatusStyle(
    label: 'Resubmitted',
    bg: Color(0xFFE0EAFF),
    text: Color(0xFF1D4ED8),
  ),
  'approved': _StatusStyle(
    label: 'Approved',
    bg: Color(0xFFE7F6EC),
    text: Color(0xFF036B26),
  ),
  'rejected': _StatusStyle(
    label: 'Rejected',
    bg: Color(0xFFFEF3F2),
    text: Color(0xFFB42318),
  ),
};

_StatusStyle _getStyle(String status) =>
    _statusStyles[status.toLowerCase()] ?? _statusStyles['draft']!;

class ScheduleScreen extends ConsumerStatefulWidget {
  final String? projectId;
  final String? bidId;
  final bool isEmbedded;

  const ScheduleScreen({
    super.key,
    this.projectId,
    this.bidId,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  String? _expandedPhaseId;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Removed aggressive auto-refresh timer which was causing 
    // infinite skeleton loops on poor connections.
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Widget _buildScheduleSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEAECF0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _shimmerBox(width: 140, height: 20),
                    const Spacer(),
                    _shimmerBox(width: 80, height: 24, radius: 999),
                  ],
                ),
                const SizedBox(height: 12),
                _shimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                _shimmerBox(width: 200, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < 3; i++) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEAECF0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(width: 160, height: 14),
                        const SizedBox(height: 6),
                        _shimmerBox(width: 120, height: 12),
                      ],
                    ),
                  ),
                  _shimmerBox(width: 30, height: 30, radius: 999),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(projectScheduleProvider(widget.projectId!));
    final userRole = ref.watch(authProvider).value?.role ?? UserRole.unknown;
    final isOwner = userRole == UserRole.projectOwner;

    ref.listen(scheduleActionProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Action successful'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        error: (err, _) {
          final errStr = err.toString().toLowerCase();
          String message = 'Error: $err';
          if (errStr.contains('not the assigned contractor')) {
            message =
                'Information: Schedules can only be officially created after the project is awarded. You can use the Library to plan your proposal timeline.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: errStr.contains('not the assigned contractor')
                  ? Colors.orange
                  : Colors.red,
            ),
          );
        },
        loading: () {},
      );
    });

    final content = scheduleAsync.when(
      loading: () => scheduleAsync.hasValue
          ? _buildScheduleContent(scheduleAsync.value!, isOwner)
          : _buildScheduleSkeleton(),
      error: (error, _) {
        final errStr = error.toString().toLowerCase();
        bool isNotFound = false;

        if (error is ApiException) {
          if (error.statusCode == 404) isNotFound = true;
        }

        if (errStr.contains('404') ||
            errStr.contains('no query results') ||
            errStr.contains('not found')) {
          isNotFound = true;
        }

        if (isNotFound) {
          return _buildNoScheduleView();
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(projectScheduleProvider(widget.projectId!));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276572),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      data: (schedule) => _buildScheduleContent(schedule, isOwner),
    );

    final bottomBar = scheduleAsync.when(
      data: (schedule) {
        if (isOwner) {
          if (schedule.status == 'submitted') {
            return _buildOwnerApprovalBar(schedule);
          }
          return null;
        }
        return (['draft', 'revision_requested', 'resubmitted'].contains(schedule.status.toLowerCase())) ? _buildSubmitBar(schedule) : null;
      },
      loading: () => scheduleAsync.hasValue
          ? (isOwner
                ? (scheduleAsync.value!.status == 'submitted'
                      ? _buildOwnerApprovalBar(scheduleAsync.value!)
                      : null)
                : (['draft', 'revision_requested', 'resubmitted'].contains(scheduleAsync.value!.status.toLowerCase())
                      ? _buildSubmitBar(scheduleAsync.value!)
                      : null))
          : null,
      error: (err, stack) => null,
    );

    if (widget.isEmbedded) {
      return Column(
        children: [
          Expanded(child: content),
          ...?(bottomBar == null ? null : [bottomBar]),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Project Schedule',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: content,
      bottomNavigationBar: bottomBar,
    );
  }

  Widget _buildNoScheduleView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Color(0xFF98A2B3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Schedule Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You need to create a schedule for this project to track activities and milestones.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createInitialSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF276572),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 54),
              ),
              child: const Text(
                'Create Blank Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _createFromLibrary,
              icon: const Icon(Icons.library_books_outlined, size: 20),
              label: const Text(
                'Use Library Template',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 54),
                side: const BorderSide(color: Color(0xFF276572), width: 1.5),
                foregroundColor: const Color(0xFF276572),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent(Schedule schedule, bool isOwner) {
    return RefreshIndicator(
      onRefresh: () {
        return ref.refresh(projectScheduleProvider(widget.projectId!).future);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(schedule),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedule Phases',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                if (schedule.status == 'draft' && !isOwner)
                  TextButton.icon(
                    onPressed: () => _importFromLibrary(schedule),
                    icon: const Icon(
                      Icons.download,
                      size: 18,
                      color: Color(0xFF276572),
                    ),
                    label: const Text(
                      'Import Library',
                      style: TextStyle(
                        color: Color(0xFF276572),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (schedule.phases.isEmpty)
              _buildEmptyPhasesView(schedule, isOwner)
            else
              ...schedule.phases.map(
                (phase) => _buildPhaseItem(schedule, phase, isOwner),
              ),
            if (schedule.status == 'draft' && !isOwner) ...[
              const SizedBox(height: 16),
              _buildAddPhaseButton(schedule),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Schedule schedule) {
    final style = _getStyle(schedule.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: style.bg, shape: BoxShape.circle),
            child: Icon(Icons.info_outline, color: style.text, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule Status',
                  style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
                Text(
                  style.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: style.text,
                  ),
                ),
              ],
            ),
          ),
          if (schedule.submittedAt != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Submitted',
                  style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
                Text(
                  DateFormat(
                    'MMM d, y',
                  ).format(DateTime.parse(schedule.submittedAt!)),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPhasesView(Schedule schedule, bool isOwner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEAECF0),
          style: BorderStyle.none,
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.layers_clear_outlined, size: 48, color: Color(0xFFD0D5DD)),
          SizedBox(height: 12),
          Text(
            'No phases added yet',
            style: TextStyle(color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseItem(Schedule schedule, SchedulePhase phase, bool isOwner) {
    final isExpanded = _expandedPhaseId == phase.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAECF0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _expandedPhaseId = isExpanded ? null : phase.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phase ${phase.order}: ${phase.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${phase.activitiesCount} Activities',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (schedule.status == 'draft' && !isOwner)
                    PopupMenuButton<String>(
                      onSelected: (val) =>
                          _handlePhaseAction(val, schedule, phase),
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Color(0xFF667085),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Phase'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete Phase',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFF667085),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final activitiesAsync = ref.watch(phaseActivitiesProvider(
                          (scheduleId: schedule.id, phaseId: phase.id)));

                      return activitiesAsync.when(
                        data: (activities) {
                          if (activities.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No activities in this phase',
                                style: TextStyle(color: Color(0xFF98A2B3)),
                              ),
                            );
                          }
                          return Column(
                            children: activities
                                .map((activity) => _buildActivityItem(
                                      schedule,
                                      phase,
                                      activity,
                                      isOwner,
                                    ))
                                .toList(),
                          );
                        },
                        loading: () => Column(
                          children: List.generate(
                            phase.activitiesCount > 0 ? phase.activitiesCount : 2,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _shimmerBox(width: double.infinity, height: 60),
                            ),
                          ),
                        ),
                        error: (error, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Error loading activities: $error',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (schedule.status == 'draft' && !isOwner)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _addActivity(schedule, phase),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Activity'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    Schedule schedule,
    SchedulePhase phase,
    ScheduleActivity activity,
    bool isOwner,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (activity.activityCode != null)
                      Text(
                        activity.activityCode!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF667085),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (schedule.status == 'draft' && !isOwner)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF667085),
                      ),
                      onPressed: () => _editActivity(schedule, phase, activity),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFD92D20),
                      ),
                      onPressed: () =>
                          _deleteActivity(schedule, phase, activity),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (activity.deadline != null) ...[
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Color(0xFF667085),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat(
                    'MMM d, y',
                  ).format(DateTime.parse(activity.deadline!)),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              const Icon(
                Icons.timer_outlined,
                size: 12,
                color: Color(0xFF667085),
              ),
              const SizedBox(width: 4),
              Text(
                '${activity.standardDurationDays ?? 0} days',
                style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
              ),
            ],
          ),
          if (activity.assignedTo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 12,
                  color: Color(0xFF667085),
                ),
                const SizedBox(width: 4),
                Text(
                  activity.assignedTo!.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF344054),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPhaseButton(Schedule schedule) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _addPhase(schedule),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add New Phase',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFF276572), width: 1.5),
          foregroundColor: const Color(0xFF276572),
        ),
      ),
    );
  }

  Widget _buildSubmitBar(Schedule schedule) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _confirmSubmitSchedule(schedule),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF276572),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 54),
        ),
        child: const Text(
          'Submit Schedule for Approval',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // --- ACTIONS ---

  void _createInitialSchedule() async {
    final notes = await _showNotesDialog();
    if (notes == null) return;

    if (widget.bidId != null) {
      await ref
          .read(scheduleActionProvider.notifier)
          .createScheduleFromBid(widget.bidId!, notes);
    } else if (widget.projectId != null) {
      await ref
          .read(scheduleActionProvider.notifier)
          .createScheduleFromProject(widget.projectId!, notes);
    }
  }

  void _createFromLibrary() async {
    final notes = await _showNotesDialog();
    if (notes == null) return;

    try {
      // 1. Create the schedule record
      Schedule? schedule;
      if (widget.bidId != null) {
        schedule = await ref
            .read(scheduleRepositoryProvider)
            .createScheduleFromBid(widget.bidId!, notes);
      } else if (widget.projectId != null) {
        schedule = await ref
            .read(scheduleRepositoryProvider)
            .createScheduleFromProject(widget.projectId!, notes);
      }

      if (schedule != null && mounted) {
        // 2. Refresh local state
        if (widget.projectId != null) {
          ref.invalidate(projectScheduleProvider(widget.projectId!));
        }

        // 3. Immediately push to library import
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduleLibraryImportScreen(
              scheduleId: schedule!.id,
              projectId: widget.projectId,
              bidId: widget.bidId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating schedule: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _showNotesDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Notes'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add any notes for the project owner...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              foregroundColor: Colors.white, // Ensure text is white
            ),
            child: const Text(
              'Create',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _addPhase(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => SchedulePhaseDialog(
        onSave: (data) => ref.read(scheduleActionProvider.notifier).createPhase(
              schedule.id,
              projectId: widget.projectId,
              bidId: widget.bidId,
              data: data,
            ),
      ),
    );
  }

  void _handlePhaseAction(
    String action,
    Schedule schedule,
    SchedulePhase phase,
  ) {
    if (action == 'edit') {
      showDialog(
        context: context,
        builder: (context) => SchedulePhaseDialog(
          phase: phase,
          onSave: (data) => ref.read(scheduleActionProvider.notifier).updatePhase(
                schedule.id,
                phase.id,
                projectId: widget.projectId,
                bidId: widget.bidId,
                data: data,
              ),
        ),
      );
    } else if (action == 'delete') {
      _confirmDeletePhase(schedule, phase);
    }
  }

  void _confirmDeletePhase(Schedule schedule, SchedulePhase phase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Phase'),
        content: Text(
          'Are you sure you want to delete phase "${phase.name}"? This will delete all activities within it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scheduleActionProvider.notifier).deletePhase(
                    schedule.id,
                    phase.id,
                    projectId: widget.projectId,
                    bidId: widget.bidId,
                  );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addActivity(Schedule schedule, SchedulePhase phase) {
    showDialog(
      context: context,
      builder: (context) => ScheduleActivityDialog(
        projectId: schedule.projectId,
        onSave: (data) =>
            ref.read(scheduleActionProvider.notifier).createActivity(
                  schedule.id,
                  phase.id,
                  projectId: schedule.projectId,
                  bidId: widget.bidId,
                  data: data,
                ),
      ),
    );
  }

  void _editActivity(
    Schedule schedule,
    SchedulePhase phase,
    ScheduleActivity activity,
  ) {
    showDialog(
      context: context,
      builder: (context) => ScheduleActivityDialog(
        projectId: schedule.projectId,
        activity: activity,
        onSave: (data) =>
            ref.read(scheduleActionProvider.notifier).updateActivity(
                  schedule.id,
                  phase.id,
                  activity.id,
                  projectId: schedule.projectId,
                  bidId: widget.bidId,
                  data: data,
                ),
      ),
    );
  }

  void _deleteActivity(
    Schedule schedule,
    SchedulePhase phase,
    ScheduleActivity activity,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text(
          'Are you sure you want to delete activity "${activity.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scheduleActionProvider.notifier).deleteActivity(
                    schedule.id,
                    phase.id,
                    activity.id,
                    projectId: widget.projectId,
                    bidId: widget.bidId,
                  );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _importFromLibrary(Schedule schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleLibraryImportScreen(
          scheduleId: schedule.id,
          projectId: widget.projectId,
          bidId: widget.bidId,
        ),
      ),
    );
  }

  void _confirmSubmitSchedule(Schedule schedule) {
    final controller = TextEditingController(text: schedule.contractorNotes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to submit this schedule for approval? You will not be able to edit it once submitted.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Any final notes for the project owner...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF667085)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(scheduleActionProvider.notifier).submitSchedule(
                    schedule.id,
                    widget.projectId,
                    widget.bidId,
                    controller.text,
                  );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Submit for Approval',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerApprovalBar(Schedule schedule) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _requestRevision(schedule),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: const BorderSide(color: Color(0xFFD92D20)),
                foregroundColor: const Color(0xFFD92D20),
              ),
              child: const Text(
                'Request Revision',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _approveSchedule(schedule),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12B76A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _approveSchedule(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Schedule'),
        content: const Text(
          'Are you sure you want to approve this schedule? This will set the project timeline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(scheduleActionProvider.notifier)
                      .approveSchedule(schedule.id, schedule.projectId);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF12B76A),
                ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _requestRevision(Schedule schedule) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Revision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide feedback on what needs to be changed.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                hintText: 'e.g., Please adjust the foundation phase dates...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(scheduleActionProvider.notifier)
                      .requestRevision(
                        schedule.id,
                        schedule.projectId,
                        controller.text,
                      );
                  Navigator.pop(context);
                },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD92D20),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
