import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/providers/wizard_provider.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/models/new_project_state.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/widgets/shared_widgets.dart';
import 'package:converf/features/contractors/providers/contractor_providers.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/team/add_team_modal.dart';
import 'package:converf/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class StepTimeline extends ConsumerStatefulWidget {
  const StepTimeline({super.key});

  @override
  ConsumerState<StepTimeline> createState() => _StepTimelineState();
}

class _StepTimelineState extends ConsumerState<StepTimeline> {
  late TextEditingController _budgetController;
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final state = ref.read(wizardStateProvider);
    
    // Format initial budget with commas
    String initialBudget = state.budget;
    if (initialBudget.isNotEmpty) {
      final formatter = NumberFormat('#,###');
      try {
        final double val = double.parse(initialBudget.replaceAll(RegExp(r'[^0-9]'), ''));
        initialBudget = formatter.format(val);
      } catch (_) {}
    }
    
    _budgetController = TextEditingController(text: initialBudget);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WizardSectionHeader(title: 'Timeline', iconPath: 'assets/images/routing-2.svg'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: WizardDatePicker(
                label: 'Start Date*',
                date: state.startDate,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
              if (date != null) {
                notifier.updateTimelineBudget(startDate: date);
                // Ensure bidding deadline is before start date
                if (state.biddingDeadline != null && !state.biddingDeadline!.isBefore(date)) {
                  notifier.updateTimelineBudget(biddingDeadline: date.subtract(const Duration(days: 1)));
                }
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WizardDatePicker(
            label: 'End Date*',
            date: state.endDate,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.startDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: state.startDate?.add(const Duration(days: 1)) ?? DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) notifier.updateTimelineBudget(endDate: date);
            },
          ),
        ),
      ],
    ),
    const SizedBox(height: 32),
    const WizardSectionHeader(title: 'Budgeting', iconPath: 'assets/images/Subtract.svg'),
    const SizedBox(height: 16),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: WizardDropdown(
            label: 'Currency*',
            value: state.currency,
            items: const ['NGN', 'USD'],
            onChanged: (val) => notifier.updateTimelineBudget(currency: val ?? 'NGN'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: WizardTextField(
            label: 'Total Budget Amount*',
            controller: _budgetController,
            hint: 'e.g., 450,000,000',
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            prefix: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                state.currency == 'USD' ? '\$' : '\u20A6',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            onChanged: (val) {
              final cleanVal = val.replaceAll(',', '');
              notifier.updateTimelineBudget(budget: cleanVal);
            },
          ),
        ),
      ],
    ),
    const SizedBox(height: 32),
    const WizardSectionHeader(title: 'Project Urgency', iconPath: 'assets/images/Target.svg'),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WizardPriorityButton(
            priority: 'low',
            title: 'Low',
            icon: SvgPicture.asset('assets/images/logo.svg', width: 20, height: 20),
            isActive: state.urgencyLevel == 'low',
            onTap: () => notifier.updateTimelineBudget(urgencyLevel: 'low'),
          ),
          WizardPriorityButton(
            priority: 'medium',
            title: 'Medium',
            icon: SvgPicture.asset('assets/images/logo.svg', width: 20, height: 20),
            isActive: state.urgencyLevel == 'medium',
            onTap: () => notifier.updateTimelineBudget(urgencyLevel: 'medium'),
          ),
          WizardPriorityButton(
            priority: 'high',
            title: 'High',
            icon: SvgPicture.asset('assets/images/Target.svg', width: 20, height: 20),
            isActive: state.urgencyLevel == 'high',
            onTap: () => notifier.updateTimelineBudget(urgencyLevel: 'high'),
          ),
          WizardPriorityButton(
            priority: 'critical',
            title: 'Critical',
            icon: SvgPicture.asset('assets/images/shield-warning.svg', width: 20, height: 20),
            isActive: state.urgencyLevel == 'critical',
            onTap: () => notifier.updateTimelineBudget(urgencyLevel: 'critical'),
          ),
        ],
      ),
    ),
    const SizedBox(height: 32),
    const WizardSectionHeader(title: 'Assign Contractor', iconPath: 'assets/images/Plate.svg'),
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: AssignmentOption(
            type: 'direct',
            title: 'Assign\nDirectly',
            imagePath: 'assets/images/group-1.svg',
            isSelected: state.assignmentMethod == 'direct',
            onTap: () => notifier.updateTimelineBudget(assignmentMethod: 'direct'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AssignmentOption(
            type: 'tender',
            title: 'Post to\nTender',
            imagePath: 'assets/images/projects.svg',
            isSelected: state.assignmentMethod == 'tender',
            onTap: () {
              notifier.updateTimelineBudget(
                assignmentMethod: 'tender',
                selectedContractorId: null,
              );
              // Automatically set a sensible bidding deadline if none exists
              if (state.biddingDeadline == null && state.startDate != null) {
                 notifier.updateTimelineBudget(biddingDeadline: state.startDate?.subtract(const Duration(days: 1)));
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AssignmentOption(
            type: 'decide_later',
            title: 'Decide\nLater',
            imagePath: 'assets/images/Calendar-1.svg',
            isSelected: state.assignmentMethod == 'decide_later',
            onTap: () => notifier.updateTimelineBudget(
              assignmentMethod: 'decide_later',
              selectedContractorId: null,
            ),
          ),
        ),
      ],
    ),
    if (state.assignmentMethod == 'direct') ...[
      const SizedBox(height: 24),
      _buildContractorSelection(context, ref, state, notifier),
    ] else if (state.assignmentMethod == 'tender') ...[
      const SizedBox(height: 24),
      _buildTenderInfo(),
      const SizedBox(height: 24),
      WizardDatePicker(
        label: 'Bidding Deadline*',
        hint: 'Must be before start date',
        date: state.biddingDeadline,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: state.biddingDeadline ?? (state.startDate?.subtract(const Duration(days: 1)) ?? DateTime.now()),
            firstDate: DateTime.now(),
            lastDate: state.startDate?.subtract(const Duration(days: 1)) ?? DateTime(2100),
          );
          if (date != null) notifier.updateTimelineBudget(biddingDeadline: date);
        },
      ),
    ],
      ],
    );
  }

  Widget _buildContractorSelection(BuildContext context, WidgetRef ref, NewProjectState state, WizardStateNotifier notifier) {
    final contractorsAsync = ref.watch(contractorsProvider(null));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search contractors...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF98A2B3)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE4E7EC))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE4E7EC))),
            ),
          ),
          const SizedBox(height: 16),
          contractorsAsync.when(
            data: (response) {
              final contractors = response.data.where((c) {
                final matchesSearch = c.displayName.toLowerCase().contains(_searchQuery);
                return matchesSearch;
              }).toList();

              if (contractors.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    _searchQuery.isEmpty ? 'No contractors found in your team.' : 'No contractors matching "$_searchQuery"',
                    style: const TextStyle(color: Color(0xFF667185)),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                children: contractors.map((contractor) {
                    final rating = contractor.profile.rating ?? 0;
                    final projects = contractor.profile.totalProjectsCount ?? 0;
                    final specialisation = (contractor.profile.specialisations?.isNotEmpty ?? false)
                        ? contractor.profile.specialisations!.first.toUpperCase()
                        : 'CONTRACTOR';
                    final name = contractor.companyName.isNotEmpty
                        ? contractor.companyName
                        : contractor.displayName;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildContractorCard(
                        name,
                        contractor.avatarUrl ?? 'assets/images/africa.png',
                        rating,
                        projects,
                        specialisation,
                        state,
                        notifier,
                        contractor.id,
                      ),
                    );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading contractors: $err', style: const TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddTeamModal(
                    onNavigateToProjects: () {
                      Navigator.of(context).pop();
                      ref.invalidate(contractorsProvider(null));
                    },
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20, color: Color(0xFF6B7280)),
              label: const Text('Invite Contractor', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractorCard(String name, String image, double rating, int projects, String category, NewProjectState state, WizardStateNotifier notifier, String id) {
    bool isSelected = state.selectedContractorId == id;
    return GestureDetector(
      onTap: () => notifier.updateTimelineBudget(selectedContractorId: id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FBFB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF309DAA) : const Color(0xFFE4E7EC)),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: AssetImage(image)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF97316), size: 14),
                      Text(' $rating ($projects Projects)', style: const TextStyle(fontSize: 12, color: Color(0xFF667185))),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(4)),
              child: Text(category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF344054))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF0086C9), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Post to Tender', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0086C9))),
                SizedBox(height: 4),
                Text(
                  'Your project will be visible to all qualified contractors. They will submit bids for you to review.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF0086C9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
