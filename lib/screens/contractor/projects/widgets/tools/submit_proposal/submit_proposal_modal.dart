import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/marketplace/models/marketplace_responses.dart';
import 'package:converf/features/marketplace/providers/marketplace_providers.dart';
import 'package:converf/screens/contractor/projects/schedule/schedule_screen.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/marketplace_screen.dart';

class SubmitProposalModal extends ConsumerStatefulWidget {
  final String projectId;
  
  const SubmitProposalModal({super.key, required this.projectId});

  @override
  ConsumerState<SubmitProposalModal> createState() => _SubmitProposalModalState();
}

class _SubmitProposalModalState extends ConsumerState<SubmitProposalModal> {
  final _bidAmountController = TextEditingController();
  final _proposalController = TextEditingController();
  final _equipmentController = TextEditingController();
  
  String? _duration;
  String? _paymentPreference;
  final List<Map<String, dynamic>> _milestones = [];

  bool _isSuccess = false;
  String? _submittedBidId;

  final List<String> _durationOptions = ['1 Month', '3 Months', '6 Months', '12 Months', 'Flexible'];
  final List<String> _paymentOptions = ['Milestone-based', 'Lump Sum', 'Weekly', 'Monthly'];

  @override
  void dispose() {
    _bidAmountController.dispose();
    _proposalController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final text = _bidAmountController.text.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final amount = double.tryParse(text);
    return amount != null && amount > 0 && _proposalController.text.trim().length >= 20;
  }

  Future<void> _submitBid() async {
    if (!_isValid()) return;

    final amountText = _bidAmountController.text.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    try {
      final equipmentList = _equipmentController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final response = await ref.read(marketplaceActionProvider.notifier).submitBid(
        widget.projectId,
        SubmitBidPayload(
          amount: amount,
          proposal: _proposalController.text.trim(),
          duration: _duration,
          paymentPreference: _paymentPreference,
          equipment: equipmentList.isNotEmpty ? equipmentList : null,
          milestones: _milestones.isNotEmpty ? _milestones : null,
        ),
      );
      
      if (mounted) {
        setState(() {
          _isSuccess = true;
          _submittedBidId = response.data?.id ?? 'N/A';
        });
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: _isSuccess ? _buildSuccessScreen() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final isLoading = ref.watch(marketplaceActionProvider).isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FBFB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Color(0xFF276572),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Submit Bid',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your bid amount and proposal.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
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
        const Divider(height: 1, color: Color(0xFFF2F4F7)),
        
        // Scrollable Body
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your bid amount',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bidAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF101828)),
                  decoration: InputDecoration(
                    hintText: 'e.g., 5,000,000',
                    prefixText: '₦ ',
                    prefixStyle: const TextStyle(color: Color(0xFF101828), fontWeight: FontWeight.w600),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF276572), width: 2)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                
                // Duration & Payment Preference
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Duration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054))),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD0D5DD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _duration,
                              hint: const Text('Select'),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: _durationOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setState(() => _duration = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054))),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD0D5DD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _paymentPreference,
                              hint: const Text('Select'),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: _paymentOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setState(() => _paymentPreference = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Milestones Builder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Milestones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054))),
                    TextButton.icon(
                      onPressed: _showAddMilestoneDialog,
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF276572)),
                      label: const Text('Add', style: TextStyle(color: Color(0xFF276572))),
                    ),
                  ],
                ),
                if (_milestones.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEAECF0)), borderRadius: BorderRadius.circular(8)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _milestones.length,
                      separatorBuilder: (c, i) => const Divider(height: 1, color: Color(0xFFEAECF0)),
                      itemBuilder: (context, index) {
                        final m = _milestones[index];
                        return ListTile(
                          title: Text(m['title'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          subtitle: Text('₦${m['amount']} • Due: ${m['due_date']}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            onPressed: () => setState(() => _milestones.removeAt(index)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Equipment Section
                const Text('Equipment (comma-separated)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054))),
                const SizedBox(height: 8),
                TextField(
                  controller: _equipmentController,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF101828)),
                  decoration: InputDecoration(
                    hintText: 'e.g., Excavator, Crane',
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF276572), width: 2)),
                  ),
                ),
                const SizedBox(height: 24),

                // Proposal Section
                const Text(
                  'Proposal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _proposalController,
                  maxLines: 8,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF101828)),
                  decoration: InputDecoration(
                    hintText: 'Describe why you are the best fit for this project.',
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF276572), width: 2)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ),

        // Footer
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF276572)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF276572), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isValid() && !isLoading) ? _submitBid : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    disabledBackgroundColor: const Color(0xFFD0D5DD),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Bid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A), // Vibrant green from screenshot
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text(
            'Bid Submitted',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          if (_submittedBidId != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ref: $_submittedBidId',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _submittedBidId!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reference ID copied to clipboard')),
                    );
                  },
                  child: const Icon(Icons.copy, size: 16, color: Color(0xFF667085)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            "You're all set.",
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 48),
          // Submit Schedule Button (Primary)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close modal
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScheduleScreen(projectId: widget.projectId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Submit Schedule',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Go to My Bids Button (Outlined with Arrow Icon)
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // Close modal
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MarketplaceScreen(initialShowMyBids: true),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF276572)),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Go to My Bids',
                  style: TextStyle(
                    color: Color(0xFF276572),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.north_east, size: 18, color: Color(0xFF276572)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController(); // Simple string for now, could use DatePicker

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Milestone', style: TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Foundation completion')),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₦)')),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Due Date', hintText: 'YYYY-MM-DD')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                setState(() {
                  _milestones.add({
                    'title': titleCtrl.text.trim(),
                    'amount': double.tryParse(amountCtrl.text.trim()) ?? 0.0,
                    'due_date': dateCtrl.text.trim(),
                  });
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF276572), foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
