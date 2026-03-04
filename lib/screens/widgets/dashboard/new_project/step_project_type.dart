import 'package:flutter/material.dart';

class StepProjectType extends StatelessWidget {
  final int? selectedIndex;
  final List<Map<String, String>> projectTypes;
  final ValueChanged<int> onSelected;

  const StepProjectType({
    super.key,
    required this.selectedIndex,
    required this.projectTypes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 164.5 / 172,
          ),
          itemCount: projectTypes.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;
            final type = projectTypes[index];

            return GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.only(
                  top: 18,
                  right: 22,
                  bottom: 18,
                  left: 22,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF0FBFB)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF309DAA)
                        : Colors.transparent,
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
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFEDD5),
                          width: 1.5,
                        ),
                      ),
                      child: Image.asset(
                        type['icon']!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      type['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
