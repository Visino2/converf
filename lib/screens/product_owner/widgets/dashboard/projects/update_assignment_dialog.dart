import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/contractors/providers/contractor_providers.dart';
import '../../../../../features/projects/providers/project_providers.dart';
import '../../../../../features/projects/repositories/project_repository.dart';

class UpdateAssignmentDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String currentAssignmentMethod;
  final String? currentContractorId;
  final String? currentBiddingDeadline;

  const UpdateAssignmentDialog({
    super.key,
    required this.projectId,
    required this.currentAssignmentMethod,
    this.currentContractorId,
    this.currentBiddingDeadline,
  });

  @override
  ConsumerState<UpdateAssignmentDialog> createState() => _UpdateAssignmentDialogState();
}

class _UpdateAssignmentDialogState extends ConsumerState<UpdateAssignmentDialog> {
  late String _selectedMethod;
  String? _selectedContractorId;
  DateTime? _biddingDeadline;
  bool _isLoading = false;

  static const _methodLabels = {
    'direct': 'Assign Directly',
    'tender': 'Post to Tender',
    'self_managed': 'Self Manage',
  };

  @override
  void initState() {
    super.initState();
    // Map decide_later → tender as default
    final method = widget.currentAssignmentMethod;
    _selectedMethod = (method == 'direct' || method == 'self_managed') ? method : 'tender';
    _selectedContractorId = widget.currentContractorId;
    if (widget.currentBiddingDeadline != null) {
      _biddingDeadline = DateTime.tryParse(widget.currentBiddingDeadline!);
    }
  }

  Future<void> _submit() async {
    if (_selectedMethod == 'direct' && _selectedContractorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a contractor.')),
      );
      return;
    }
    if (_selectedMethod == 'tender' && _biddingDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bidding deadline is required.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(projectRepositoryProvider);
      await repo.updateProjectAssignment(
        widget.projectId,
        assignmentMethod: _selectedMethod,
        contractorId: _selectedMethod == 'direct' ? _selectedContractorId : null,
        biddingDeadline: _selectedMethod == 'tender' && _biddingDeadline != null
            ? _biddingDeadline!.toIso8601String().split('T')[0]
            : null,
      );

      ref.invalidate(projectDetailsProvider(widget.projectId));
      ref.invalidate(projectsListProvider(1));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment updated successfully.')),
        );
      }
    } catch (e) {
      // Refresh stale project data regardless of error type
      ref.invalidate(projectDetailsProvider(widget.projectId));
      ref.invalidate(projectsListProvider(1));

      if (mounted) {
        final raw = e.toString();
        final isNotDecideLater = raw.toLowerCase().contains('decide_later');
        if (isNotDecideLater) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This project assignment has already been set. Refreshing...'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          final msg = raw.contains('Exception:')
              ? raw.split('Exception:').last.trim()
              : raw;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: $msg')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _biddingDeadline ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _biddingDeadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    final contractorsAsync = ref.watch(contractorsProvider(null));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Assignment',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose how to assign this project and save your update.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),

          // Body
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assignment Method dropdown
                const Text(
                  'Assignment Method',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF344054)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedMethod,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    isDense: true,
                  ),
                  items: _methodLabels.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: _isLoading ? null : (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMethod = val;
                        if (val == 'direct') _biddingDeadline = null;
                        if (val == 'tender') _selectedContractorId = null;
                        if (val == 'self_managed') {
                          _selectedContractorId = null;
                          _biddingDeadline = null;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Conditional sections
                if (_selectedMethod == 'direct') ...[
                  const Text(
                    'Select Contractor',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF344054)),
                  ),
                  const SizedBox(height: 8),
                  contractorsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, _) => const Text('Unable to load contractors', style: TextStyle(color: Colors.red)),
                    data: (res) {
                      final contractors = res.data;
                      if (contractors.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEAECF0)),
                          ),
                          child: const Text(
                            'No contractors available. Use "Post to Tender" to find contractors.',
                            style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                          ),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedContractorId,
                        hint: const Text('Choose a contractor'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          isDense: true,
                        ),
                        items: contractors
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.companyName.isNotEmpty ? c.companyName : c.displayName),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedContractorId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                if (_selectedMethod == 'tender') ...[
                  const Text(
                    'Bidding Deadline',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF344054)),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD0D5DD)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _biddingDeadline != null
                                ? '${_biddingDeadline!.year}-${_biddingDeadline!.month.toString().padLeft(2, '0')}-${_biddingDeadline!.day.toString().padLeft(2, '0')}'
                                : 'Pick a date',
                            style: TextStyle(
                              color: _biddingDeadline != null ? const Color(0xFF101828) : const Color(0xFF98A2B3),
                              fontSize: 14,
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF667085)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                if (_selectedMethod == 'self_managed')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FBF6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD5E7DA)),
                    ),
                    child: const Text(
                      'The project owner will manage schedule execution, inspections, and daily reporting directly on this project.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1F5131)),
                    ),
                  ),
              ],
            ),
          ),
            ),
          ),

          // Footer buttons
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF276572)),
                    foregroundColor: const Color(0xFF276572),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Assignment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
