import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/providers/wizard_provider.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/models/new_project_state.dart';

class StepType extends ConsumerWidget {
  const StepType({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('StepType: building...');
    final state = ref.watch(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);

    final List<Map<String, String>> projectTypes = [
      {'title': 'Residential\nConstruction', 'icon': 'assets/images/home-1.svg', 'value': 'residential'},
      {'title': 'Commercial\nConstruction', 'icon': 'assets/images/Buildings.svg', 'value': 'commercial'},
      {'title': 'Roadway\nConstruction', 'icon': 'assets/images/truck.svg', 'value': 'roadway'},
      {'title': 'Infrastructure\nProjects', 'icon': 'assets/images/crane.svg', 'value': 'infrastructure'},
    ];

    final Map<String, List<String>> subTypeOptions = {
      'commercial': ['Office', 'Retail', 'Hospitality', 'Industrial', 'Medical'],
    };

    // PERFORMANCE RULE: Never use shrinkWrap: true on a GridView/ListView inside a 
    // bottom sheet or modal. It causes O(N^2) layout passes and locks the UI thread.
    // Use this manual Column/Row approach for a fixed number of items.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'What are you building?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the primary type of your construction project',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Efficient hand-rolled grid for 4 items
        Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTypeCard(context, ref, projectTypes[0], state, notifier, 0)),
                const SizedBox(width: 16),
                Expanded(child: _buildTypeCard(context, ref, projectTypes[1], state, notifier, 1)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTypeCard(context, ref, projectTypes[2], state, notifier, 2)),
                const SizedBox(width: 16),
                Expanded(child: _buildTypeCard(context, ref, projectTypes[3], state, notifier, 3)),
              ],
            ),
          ],
        ),
        if (state.selectedIndex != null && projectTypes[state.selectedIndex!]['value'] == 'commercial') ...[
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Commercial Sub-Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (subTypeOptions['commercial'] ?? []).map((subType) {
              final isSelected = state.selectedSubType == subType;
              return GestureDetector(
                onTap: () => notifier.updateBasicInfo(selectedSubType: subType),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2A8090) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2A8090) : const Color(0xFFE4E7EC),
                    ),
                  ),
                  child: Text(
                    subType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF667185),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeCard(BuildContext context, WidgetRef ref, Map<String, String> type, NewProjectState state, WizardStateNotifier notifier, int index) {
    final isSelected = state.selectedIndex == index;

    return GestureDetector(
      onTap: () => notifier.updateBasicInfo(
        selectedIndex: index,
        selectedType: type['value'],
        selectedSubType: state.selectedType == type['value'] ? state.selectedSubType : null,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FBFB) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF309DAA) : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFEDD5),
                  width: 1.5,
                ),
              ),
              child: SvgPicture.asset(
                type['icon']!,
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(Color(0xFFF97316), BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              type['title']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF276572) : const Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
