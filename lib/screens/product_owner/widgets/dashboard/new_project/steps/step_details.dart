import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/providers/wizard_provider.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/widgets/shared_widgets.dart';

class StepDetails extends ConsumerStatefulWidget {
  const StepDetails({super.key});

  @override
  ConsumerState<StepDetails> createState() => _StepDetailsState();
}

class _StepDetailsState extends ConsumerState<StepDetails> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(wizardStateProvider);
    _nameController = TextEditingController(text: state.title);
    _descController = TextEditingController(text: state.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('StepDetails: building...');
    final notifier = ref.read(wizardStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WizardTextField(
          label: 'Project Name*',
          controller: _nameController,
          hint: 'e.g., Lekki Residential Estate Phase 2',
          onChanged: (val) => notifier.updateBasicInfo(title: val),
        ),
        const SizedBox(height: 16),
        WizardTextField(
          label: 'Project Description*',
          controller: _descController,
          hint: 'Describe the scope, objectives, and key features...',
          maxLines: 4,
          onChanged: (val) => notifier.updateBasicInfo(description: val),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _descController,
          builder: (context, value, _) {
            return Text(
              '${value.text.length}/1000',
              style: const TextStyle(fontSize: 13, color: Color(0xFF667185)),
            );
          },
        ),
      ],
    );
  }
}
