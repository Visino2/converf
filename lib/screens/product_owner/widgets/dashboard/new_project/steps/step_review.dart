import 'package:flutter/material.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/models/new_project_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/providers/wizard_provider.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/widgets/shared_widgets.dart';

class StepReview extends ConsumerWidget {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);

    String projectType = state.selectedType ?? '';
    String location = '${state.city ?? ''}, ${state.state ?? ''}, ${state.country ?? ''}';
    String timeline = '${state.startDate != null ? state.startDate!.toString().substring(0, 10) : ''} to ${state.endDate != null ? state.endDate!.toString().substring(0, 10) : ''}';
    String budget = '${state.currency} ${state.budget}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FBFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8F3F5), width: 1),
          ),
          child: Row(
            children: [
              WizardLargeIcon(type: state.selectedType),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${projectType.toUpperCase()} • ${state.selectedSubType ?? ""}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2A8090)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            WizardSummaryCard(title: 'Location', value: location, iconPath: 'assets/images/map.svg'),
            WizardSummaryCard(title: 'Timeline', value: timeline, iconPath: 'assets/images/Calendar.svg'),
            WizardSummaryCard(title: 'Budget', value: budget, iconPath: 'assets/images/bill-check.svg'),
            WizardSummaryCard(title: 'Urgency', value: state.urgencyLevel.toUpperCase(), iconPath: 'assets/images/Target.svg'),
          ],
        ),
        const SizedBox(height: 24),
        _buildAssignmentSection(state),
        const SizedBox(height: 24),
        _buildSpecialisationsSection(state),
        const SizedBox(height: 24),
        _buildDescriptionSection(state),
        const SizedBox(height: 24),
        _buildConfirmationCheckboxes(state, notifier),
      ],
    );
  }

  Widget _buildAssignmentSection(NewProjectState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Assignment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEAECF0))),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF0FBFB), borderRadius: BorderRadius.circular(12)),
                  child: SvgPicture.asset(
                    state.assignmentMethod == 'tender' ? 'assets/images/projects.svg' : (state.assignmentMethod == 'direct' ? 'assets/images/group-1.svg' : 'assets/images/Calendar-1.svg'),
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.assignmentMethod == 'tender' ? 'Public Tender' : (state.assignmentMethod == 'direct' ? 'Direct Assignment' : 'Decide Later'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      if (state.assignmentMethod == 'tender' && state.biddingDeadline != null)
                        Text('Deadline: ${state.biddingDeadline!.toString().substring(0, 10)}', style: const TextStyle(fontSize: 12, color: Color(0xFF667185))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialisationsSection(NewProjectState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Specialisations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.specialisations.map<Widget>((spec) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF0FBFB), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD8F3F5))),
            child: Text(spec.toString().toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF309DAA))),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(NewProjectState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const SizedBox(height: 8),
        Text(state.description, style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5)),
      ],
    );
  }

  Widget _buildConfirmationCheckboxes(NewProjectState state, WizardStateNotifier notifier) {
    return Column(
      children: [
        _buildCheckboxRow(
          state.confirmInfo,
          (val) => notifier.updateReview(confirmInfo: val ?? false),
          'I confirm all information provided is accurate and reflect the true scope of the project.',
        ),
        const SizedBox(height: 16),
        _buildCheckboxRow(
          state.agreeTerms,
          (val) => notifier.updateReview(agreeTerms: val ?? false),
          'I agree to Converf\'s Terms & Conditions regarding project quality monitoring.',
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(bool value, Function(bool?)? onChanged, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 24, height: 24, child: Checkbox(value: value, onChanged: onChanged, activeColor: const Color(0xFF309DAA))),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4))),
      ],
    );
  }
}
