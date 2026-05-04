import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/models/schedule.dart';
import 'package:converf/features/projects/providers/project_team_providers.dart';
import 'package:intl/intl.dart';

const _teal = Color(0xFF276572);
const _border = Color(0xFFD0D5DD);
const _labelColor = Color(0xFF344054);
const _hintColor = Color(0xFF98A2B3);

InputDecoration _fieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(color: _labelColor, fontSize: 14),
    hintStyle: const TextStyle(color: _hintColor, fontSize: 14),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _teal, width: 1.5),
    ),
  );
}

Widget _dateField({
  required String label,
  required String? value,
  required VoidCallback onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _labelColor,
        ),
      ),
      const SizedBox(height: 6),
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: value != null ? const Color(0xFFF0FBFB) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value != null ? _teal : _border,
                width: value != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: _teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value ?? 'Pick a date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: value != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: value != null
                          ? const Color(0xFF101828)
                          : _hintColor,
                    ),
                  ),
                ),
                if (value != null)
                  const Icon(Icons.check_circle, size: 16, color: _teal)
                else
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: _hintColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Future<String?> _pickDate(BuildContext context, {String? current}) async {
  DateTime initial = DateTime.now();
  if (current != null && current.isNotEmpty) {
    initial = DateTime.tryParse(current) ?? DateTime.now();
  }
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (ctx, child) => Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: _teal,
          onPrimary: Colors.white,
          onSurface: Color(0xFF101828),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _teal),
        ),
      ),
      child: child!,
    ),
  );
  if (picked == null) return null;
  return DateFormat('yyyy-MM-dd').format(picked);
}

// ─── Phase Dialog ──────────────────────────────────────────────────────────

class SchedulePhaseDialog extends StatefulWidget {
  final SchedulePhase? phase;
  final int defaultOrder;
  final Function(Map<String, dynamic>) onSave;

  const SchedulePhaseDialog({
    super.key,
    this.phase,
    this.defaultOrder = 1,
    required this.onSave,
  });

  @override
  State<SchedulePhaseDialog> createState() => _SchedulePhaseDialogState();
}

class _SchedulePhaseDialogState extends State<SchedulePhaseDialog> {
  final _nameController = TextEditingController();
  final _orderController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.phase != null) {
      _nameController.text = widget.phase!.name;
      _orderController.text = widget.phase!.order.toString();
      _startDate = widget.phase!.startDate;
      _endDate = widget.phase!.endDate;
      if (widget.phase!.budgetAmount != null) {
        _budgetController.text = _formatAmount(widget.phase!.budgetAmount!);
      }
    } else {
      _orderController.text = widget.defaultOrder.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    final formatted = NumberFormat('#,##0.##').format(value);
    return formatted;
  }

  double? _parseAmount(String raw) {
    final clean = raw.replaceAll(',', '').trim();
    return double.tryParse(clean);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.phase != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FBFB),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.view_list_rounded,
                    color: _teal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Phase' : 'Add New Phase',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const Text(
                        'Set phase name, dates and budget',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF737373),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF667085),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: _fieldDecoration(
                      'Phase Name',
                      hint: 'e.g., Foundation',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _orderController,
                    decoration: _fieldDecoration('Order', hint: 'e.g., 1'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _budgetController,
                    decoration: _fieldDecoration(
                      'Budget Amount (₦)',
                      hint: 'e.g., 5,000,000',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          label: 'Start Date',
                          value: _startDate,
                          onTap: () async {
                            final d = await _pickDate(
                              context,
                              current: _startDate,
                            );
                            if (d != null) setState(() => _startDate = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateField(
                          label: 'End Date',
                          value: _endDate,
                          onTap: () async {
                            final d = await _pickDate(
                              context,
                              current: _endDate,
                            );
                            if (d != null) setState(() => _endDate = d);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _teal,
                      side: const BorderSide(color: _teal),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isEmpty) return;
                      final order = int.tryParse(_orderController.text) ?? 1;
                      widget.onSave({
                        'name': _nameController.text.trim(),
                        'order': order,
                        if (_startDate != null) 'start_date': _startDate,
                        if (_endDate != null) 'end_date': _endDate,
                        if (_budgetController.text.isNotEmpty)
                          'budget_amount': _parseAmount(_budgetController.text),
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'Save Changes' : 'Create Phase',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
}

// ─── Activity Dialog ────────────────────────────────────────────────────────

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
  ConsumerState<ScheduleActivityDialog> createState() =>
      _ScheduleActivityDialogState();
}

class _ScheduleActivityDialogState
    extends ConsumerState<ScheduleActivityDialog> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _roleController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _deadline;
  String? _selectedAssigneeId;
  bool _canRunParallel = false;
  bool _isMilestone = false;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      final a = widget.activity!;
      _titleController.text = a.title;
      _deadline = a.deadline;
      _durationController.text = a.standardDurationDays?.toString() ?? '1';
      _roleController.text = a.assignedRoleLabel ?? '';
      _selectedAssigneeId = a.assignedTo?.id;
      _canRunParallel = a.canRunParallel;
      _isMilestone = a.isMilestone;
      if (a.budgetAmount != null) {
        _budgetController.text = NumberFormat(
          '#,##0.##',
        ).format(a.budgetAmount!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _roleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  double? _parseAmount(String raw) {
    final clean = raw.replaceAll(',', '').trim();
    return double.tryParse(clean);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.activity != null;
    final teamAsync = ref.watch(projectTeamProvider(widget.projectId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FBFB),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: _teal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Activity' : 'Add New Activity',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const Text(
                        'Set activity details and budget',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF737373),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF667085),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: _fieldDecoration(
                      'Activity Title',
                      hint: 'Enter activity title',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _roleController,
                    decoration: _fieldDecoration(
                      'Assigned Role (Optional)',
                      hint: 'e.g., Plumber, Engineer',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _budgetController,
                    decoration: _fieldDecoration(
                      'Budget Amount (₦)',
                      hint: 'e.g., 1,500,000',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _dateField(
                    label: 'Deadline',
                    value: _deadline,
                    onTap: () async {
                      final d = await _pickDate(context, current: _deadline);
                      if (d != null) setState(() => _deadline = d);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _durationController,
                    decoration: _fieldDecoration(
                      'Duration (Days)',
                      hint: 'e.g., 5',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  teamAsync.when(
                    data: (team) => DropdownButtonFormField<String>(
                      initialValue: _selectedAssigneeId,
                      decoration: _fieldDecoration('Assign To (Optional)'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('None'),
                        ),
                        ...team.map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.displayName),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedAssigneeId = val),
                    ),
                    loading: () => const LinearProgressIndicator(color: _teal),
                    error: (err, st) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  _CheckRow(
                    label: 'Can run in parallel',
                    value: _canRunParallel,
                    onChanged: (v) => setState(() => _canRunParallel = v),
                  ),
                  const SizedBox(height: 4),
                  _CheckRow(
                    label: 'Is Milestone',
                    value: _isMilestone,
                    onChanged: (v) => setState(() => _isMilestone = v),
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _teal,
                      side: const BorderSide(color: _teal),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.trim().isEmpty) return;
                      widget.onSave({
                        'title': _titleController.text.trim(),
                        if (_deadline != null) 'deadline': _deadline,
                        if (_budgetController.text.isNotEmpty)
                          'budget_amount': _parseAmount(_budgetController.text),
                        'standard_duration_days':
                            int.tryParse(_durationController.text) ?? 1,
                        if (_roleController.text.isNotEmpty)
                          'assigned_role_label': _roleController.text.trim(),
                        if (_selectedAssigneeId != null)
                          'assigned_to': _selectedAssigneeId,
                        'can_run_parallel': _canRunParallel,
                        'is_milestone': _isMilestone,
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'Save Changes' : 'Create Activity',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? _teal : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: value ? _teal : _border, width: 1.5),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: _labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
