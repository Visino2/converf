import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/providers/wizard_provider.dart';

class StepSpecialisations extends ConsumerWidget {
  const StepSpecialisations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);

    final List<Map<String, String>> specialisationOptions = [
      {'value': 'residential', 'label': 'Residential'},
      {'value': 'infrastructure', 'label': 'Infrastructure'},
      {'value': 'commercial', 'label': 'Commercial'},
      {'value': 'industrial', 'label': 'Industrial'},
      {'value': 'roadway', 'label': 'Roadway'},
      {'value': 'renovation', 'label': 'Renovation'},
      {'value': 'carpentry', 'label': 'Carpentry'},
      {'value': 'plumbing', 'label': 'Plumbing'},
      {'value': 'electrical', 'label': 'Electrical'},
      {'value': 'masonry', 'label': 'Masonry'},
      {'value': 'roofing', 'label': 'Roofing'},
      {'value': 'painting', 'label': 'Painting'},
      {'value': 'hvac', 'label': 'HVAC'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Specialisations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2939),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the specific areas of expertise required for this project.',
          style: TextStyle(fontSize: 14, color: Color(0xFF667185)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: specialisationOptions.map((option) {
            final isSelected = state.specialisations.contains(option['value']);
            return GestureDetector(
              onTap: () {
                final current = List<String>.from(state.specialisations);
                if (isSelected) {
                  current.remove(option['value']);
                } else {
                  current.add(option['value']!);
                }
                notifier.updateSpecialisations(current);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2A8090) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2A8090) : const Color(0xFFD0D5DD),
                  ),
                ),
                child: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF344054),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
