import 'package:flutter/material.dart';

class StepProjectDetails extends StatelessWidget {
  final TextEditingController projectNameController;
  final TextEditingController projectDescController;
  final String? selectedSubType;
  final TextEditingController referenceIdController;
  final List<String> subTypes;
  final ValueChanged<String?> onSubTypeChanged;

  const StepProjectDetails({
    super.key,
    required this.projectNameController,
    required this.projectDescController,
    required this.selectedSubType,
    required this.referenceIdController,
    required this.subTypes,
    required this.onSubTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Project Name*',
          projectNameController,
          hint: 'e.g., Lekki Residential Estate Phase 2',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Project Description*',
          projectDescController,
          hint: 'Describe the scope, objectives, and key features...',
          maxLines: 4,
          onChanged: (_) {}, 
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: projectDescController,
          builder: (context, value, child) {
            return Text(
              '${value.text.length}/1000',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdown(
                'Construction Sub-type',
                selectedSubType,
                subTypes,
                onSubTypeChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'Internal Reference ID',
                referenceIdController,
                hint: 'e.g., CV-2024-001',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF309DAA)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value != null && items.contains(value) ? value : null,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          decoration: InputDecoration(
            hintText: hint ?? 'Select ${label.replaceAll('*', '').toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF309DAA)),
            ),
          ),
        ),
      ],
    );
  }
}
