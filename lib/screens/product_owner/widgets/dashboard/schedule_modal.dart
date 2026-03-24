import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:converf/core/api/api_client.dart';
import 'package:converf/features/projects/models/schedule.dart';
import 'package:converf/features/projects/providers/schedule_providers.dart';


class _StatusStyle {
  final String label;
  final Color bg;
  final Color text;
  const _StatusStyle({required this.label, required this.bg, required this.text});
}

const _statusStyles = <String, _StatusStyle>{
  'draft':               _StatusStyle(label: 'Draft',              bg: Color(0xFFF0F2F5), text: Color(0xFF475367)),
  'submitted':           _StatusStyle(label: 'Submitted',          bg: Color(0xFFFEF6E7), text: Color(0xFF865503)),
  'revision_requested':  _StatusStyle(label: 'Revision Requested', bg: Color(0xFFFFF4ED), text: Color(0xFF9A3412)),
  'resubmitted':         _StatusStyle(label: 'Resubmitted',        bg: Color(0xFFE0EAFF), text: Color(0xFF1D4ED8)),
  'approved':            _StatusStyle(label: 'Approved',           bg: Color(0xFFE7F6EC), text: Color(0xFF036B26)),
  'rejected':            _StatusStyle(label: 'Rejected',           bg: Color(0xFFFEF3F2), text: Color(0xFFB42318)),
};

_StatusStyle _getStyle(String status) =>
    _statusStyles[status.toLowerCase()] ?? _statusStyles['draft']!;

String _fmtDate(String? date) {
  if (date == null || date.isEmpty) return 'Not set';
  try {
    final d = DateTime.parse(date);
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  } catch (_) {
    return date;
  }
}

// ─── Main Modal ──────────────────────────────────────────────────────────────
class ScheduleModal extends ConsumerStatefulWidget {
  final String projectId;
  const ScheduleModal({super.key, required this.projectId});

  @override
  ConsumerState<ScheduleModal> createState() => _ScheduleModalState();
}

class _ScheduleModalState extends ConsumerState<ScheduleModal> {
  String? _expandedPhaseId;

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(projectScheduleProvider(widget.projectId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          Expanded(
            child: scheduleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
              error: (error, _) {
                final isNotFound = (error is ApiException && error.statusCode == 404) ||
                    error.toString().toLowerCase().contains('404') ||
                    error.toString().toLowerCase().contains('not found');
                if (isNotFound) return _buildEmpty();
                return Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)));
              },
              data: (schedule) {
                if (schedule.status == 'draft') return _buildEmpty();
                return _buildBody(context, schedule);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFD0D5DD), borderRadius: BorderRadius.circular(2)),
          ),
        ),
      );

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            SvgPicture.asset('assets/images/calendar-3.svg', width: 22, height: 22,
              colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
              errorBuilder: (_, __, ___) => const Icon(Icons.calendar_month, color: Color(0xFF276572))),
            const SizedBox(width: 10),
            const Text('Project Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
          ]),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 18, color: Color(0xFF667085)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.calendar_month_outlined, size: 52, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 20),
            const Text('No Schedule Submitted', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
            const SizedBox(height: 8),
            const Text(
              'Once the contractor submits a schedule, you can review and approve, request revision, or reject it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF667085), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Schedule schedule) {
    final style = _getStyle(schedule.status);
    final canReview = schedule.status == 'submitted' || schedule.status == 'resubmitted';
    final contractorName = schedule.contractor?.companyName?.isNotEmpty == true
        ? schedule.contractor!.companyName!
        : schedule.contractor != null
            ? '${schedule.contractor!.firstName} ${schedule.contractor!.lastName}'.trim()
            : 'Unknown';
    final submittedDate = _fmtDate(schedule.resubmittedAt ?? schedule.submittedAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header info card ──────────────────────────────────────────────
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
                    const Text('Project Schedule',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(999)),
                      child: Text(style.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: style.text)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Review the contractor\'s schedule and decide the next action.',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Contractor: $contractorName  •  Submitted: $submittedDate',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),

                // Contractor notes
                if (schedule.contractorNotes != null && schedule.contractorNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFCFD),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contractor Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF111827))),
                        const SizedBox(height: 4),
                        Text(schedule.contractorNotes!, style: const TextStyle(fontSize: 13, color: Color(0xFF344054))),
                      ],
                    ),
                  ),
                ],

                // Owner feedback (if revision was requested or schedule was rejected)
                if (schedule.ownerFeedback != null && schedule.ownerFeedback!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.feedback_outlined, size: 14, color: Color(0xFF9A3412)),
                            SizedBox(width: 6),
                            Text('Owner Feedback', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF9A3412))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(schedule.ownerFeedback!, style: const TextStyle(fontSize: 13, color: Color(0xFF7C2D12))),
                      ],
                    ),
                  ),
                ],

                // ── Review action buttons ────────────────────────────────────
                if (canReview) ...[
                  const SizedBox(height: 16),
                  _ReviewActions(scheduleId: schedule.id, projectId: widget.projectId),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Phases accordion ────────────────────────────────────────────
          _PhasesAccordion(
            schedule: schedule,
            expandedPhaseId: _expandedPhaseId,
            onToggle: (id) => setState(() => _expandedPhaseId = _expandedPhaseId == id ? null : id),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Review action buttons ────────────────────────────────────────────────────
class _ReviewActions extends ConsumerStatefulWidget {
  final String scheduleId;
  final String projectId;
  const _ReviewActions({required this.scheduleId, required this.projectId});

  @override
  ConsumerState<_ReviewActions> createState() => _ReviewActionsState();
}

class _ReviewActionsState extends ConsumerState<_ReviewActions> {
  Future<void> _showFeedbackDialog(BuildContext context, String action) async {
    final controller = TextEditingController();
    final isRevision = action == 'revision';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRevision ? 'Request Revision' : 'Reject Schedule',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRevision
                  ? 'Describe the changes you want the contractor to make.'
                  : 'Provide a reason for rejecting this schedule.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your feedback here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRevision ? const Color(0xFF276572) : Colors.red,
            ),
            child: Text(isRevision ? 'Request Revision' : 'Reject',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().length >= 10) {
      final notifier = ref.read(scheduleActionProvider.notifier);
      try {
        if (isRevision) {
          await notifier.requestRevision(widget.scheduleId, widget.projectId, controller.text.trim()); // revision
        } else {
          await notifier.rejectSchedule(widget.scheduleId, widget.projectId, controller.text.trim());
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isRevision ? 'Revision requested.' : 'Schedule rejected.'),
          ));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    } else if (confirmed == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback must be at least 10 characters.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(scheduleActionProvider);
    final isLoading = actionState.isLoading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => _showFeedbackDialog(context, 'revision'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF276572)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Request Revision', 
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF276572), fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _showFeedbackDialog(context, 'reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : () async {
              try {
                await ref.read(scheduleActionProvider.notifier).approveSchedule(widget.scheduleId, widget.projectId);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Schedule approved successfully.')));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to approve: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F973D),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

// ─── Phases accordion ─────────────────────────────────────────────────────────
class _PhasesAccordion extends ConsumerWidget {
  final Schedule schedule;
  final String? expandedPhaseId;
  final void Function(String) onToggle;

  const _PhasesAccordion({
    required this.schedule,
    required this.expandedPhaseId,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phases = schedule.phases;

    if (phases.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('No phases in this schedule yet.',
              style: TextStyle(fontSize: 14, color: Color(0xFF667085))),
        ),
      );
    }

    return Column(
      children: phases.map((phase) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _PhaseAccordionItem(
          phase: phase,
          scheduleId: schedule.id,
          isExpanded: expandedPhaseId == phase.id,
          onToggle: () => onToggle(phase.id),
        ),
      )).toList(),
    );
  }
}

// ─── Single expandable phase ──────────────────────────────────────────────────
class _PhaseAccordionItem extends ConsumerWidget {
  final SchedulePhase phase;
  final String scheduleId;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _PhaseAccordionItem({
    required this.phase,
    required this.scheduleId,
    required this.isExpanded,
    required this.onToggle,
  });

  String _timeline() {
    if (phase.startDate == null && phase.endDate == null) return 'No timeline set';
    return '${_fmtDate(phase.startDate)} – ${_fmtDate(phase.endDate)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use activities embedded in the phase model if available
    final activities = phase.activities;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAECF0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // ── Accordion trigger ──────────────────────────────────────
          InkWell(
            onTap: onToggle,
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
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 2),
                        Text(_timeline(), style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.list_alt, size: 14, color: Color(0xFF475367)),
                        const SizedBox(width: 4),
                        Text(
                          '${phase.activitiesCount > 0 ? phase.activitiesCount : activities.length} Activities',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475367)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF667085)),
                ],
              ),
            ),
          ),

          // ── Accordion content ──────────────────────────────────────
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: activities.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No activities in this phase yet.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF667085))),
                    )
                  : Column(
                      children: activities.map((activity) => _ActivityItem(activity: activity)).toList(),
                    ),
            ),
        ],
      ),
    );
  }
}

// ─── Activity row ─────────────────────────────────────────────────────────────
class _ActivityItem extends StatelessWidget {
  final ScheduleActivity activity;
  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAECF0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF101828))),
                const SizedBox(height: 2),
                Text(
                  '${activity.activityCode ?? 'Custom'} • '
                  '${activity.standardDurationDays != null ? '${activity.standardDurationDays} day(s)' : 'No standard duration'}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          if (activity.deadline != null) ...[
            const Icon(Icons.calendar_today, size: 13, color: Color(0xFF475467)),
            const SizedBox(width: 4),
            Text(_fmtDate(activity.deadline), style: const TextStyle(fontSize: 12, color: Color(0xFF475467))),
          ],
        ],
      ),
    );
  }
}
