import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/models/schedule.dart';
import 'package:converf/features/projects/providers/project_team_providers.dart';
import 'package:intl/intl.dart';

class SchedulePhaseDialog extends StatefulWidget {
  final SchedulePhase? phase;
  final Function(Map<String, dynamic>) onSave;

  const SchedulePhaseDialog({super.key, this.phase, required this.onSave});

  @override
  State<SchedulePhaseDialog> createState() => _SchedulePhaseDialogState();
}

class _SchedulePhaseDialogState extends State<SchedulePhaseDialog> {
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.phase != null) {
      _nameController.text = widget.phase!.name;
      _startDateController.text = widget.phase!.startDate ?? '';
      _endDateController.text = widget.phase!.endDate ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.phase == null ? 'Add Phase' : 'Edit Phase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Phase Name', hintText: 'e.g., Foundation'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _startDateController,
            decoration: const InputDecoration(labelText: 'Start Date', hintText: 'YYYY-MM-DD'),
            onTap: () => _selectDate(context, _startDateController),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _endDateController,
            decoration: const InputDecoration(labelText: 'End Date', hintText: 'YYYY-MM-DD'),
            onTap: () => _selectDate(context, _endDateController),
            readOnly: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave({
                'name': _nameController.text,
                'start_date': _startDateController.text.isNotEmpty ? _startDateController.text : null,
                'end_date': _endDateController.text.isNotEmpty ? _endDateController.text : null,
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF276572)),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}

class ScheduleActivityDialog extends ConsumerStatefulWidget {
  final String projectId;
  final ScheduleActivity? activity;
  final Function(Map<String, dynamic>) onSave;

  const ScheduleActivityDialog({
    super.key,
    required this.projectId,
    this.activity,
    required this.onSave,
  });

  @override
  ConsumerState<ScheduleActivityDialog> createState() => _ScheduleActivityDialogState();
}

class _ScheduleActivityDialogState extends ConsumerState<ScheduleActivityDialog> {
  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _durationController = TextEditingController();
  final _roleController = TextEditingController();
  String? _selectedAssigneeId;
  bool _canRunParallel = false;
  bool _isMilestone = false;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _titleController.text = widget.activity!.title;
      _deadlineController.text = widget.activity!.deadline ?? '';
      _durationController.text = widget.activity!.standardDurationDays?.toString() ?? '1';
      _roleController.text = widget.activity!.assignedRoleLabel ?? '';
      _selectedAssigneeId = widget.activity!.assignedTo?.id;
      _canRunParallel = widget.activity!.canRunParallel;
      _isMilestone = widget.activity!.isMilestone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamAsync = ref.watch(projectTeamProvider(widget.projectId));

    return AlertDialog(
      title: Text(widget.activity == null ? 'Add Activity' : 'Edit Activity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Activity Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deadlineController,
              decoration: const InputDecoration(labelText: 'Deadline', hintText: 'YYYY-MM-DD'),
              onTap: () => _selectDate(context, _deadlineController),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (Days)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Required Role', hintText: 'e.g., Plumber'),
            ),
            const SizedBox(height: 16),
            teamAsync.when(
              data: (team) => DropdownButtonFormField<String>(
                initialValue: _selectedAssigneeId,
                decoration: const InputDecoration(labelText: 'Assign To'),
                items: team.map((member) => DropdownMenuItem(
                  value: member.id,
                  child: Text(member.displayName),
                )).toList(),
                onChanged: (val) => setState(() => _selectedAssigneeId = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => const Text('Error loading team'),
            ),
            CheckboxListTile(
              title: const Text('Can run in parallel'),
              value: _canRunParallel,
              onChanged: (val) => setState(() => _canRunParallel = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Is Milestone'),
              value: _isMilestone,
              onChanged: (val) => setState(() => _isMilestone = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              widget.onSave({
                'title': _titleController.text,
                'deadline': _deadlineController.text.isNotEmpty ? _deadlineController.text : null,
                'standard_duration_days': int.tryParse(_durationController.text) ?? 1,
                'assigned_role_label': _roleController.text.isNotEmpty ? _roleController.text : null,
                'assigned_to': _selectedAssigneeId,
                'can_run_parallel': _canRunParallel,
                'is_milestone': _isMilestone,
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF276572)),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}
