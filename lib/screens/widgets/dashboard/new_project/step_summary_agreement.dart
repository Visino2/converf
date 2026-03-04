import 'package:flutter/material.dart';

class StepSummaryAgreement extends StatelessWidget {
  final Map<String, String> projectType;
  final String projectName;
  final String? selectedCountry;
  final String? selectedState;
  final String? selectedCity;
  final DateTime? startDate;
  final DateTime? endDate;
  final String selectedCurrency;
  final String budgetAmount;
  final String selectedPriority;
  final String? assignmentType;
  final DateTime? biddingDeadline;
  final String projectDescription;
  final bool confirmInfo;
  final bool agreeTerms;
  final ValueChanged<bool?> onConfirmInfoChanged;
  final ValueChanged<bool?> onAgreeTermsChanged;

  const StepSummaryAgreement({
    super.key,
    required this.projectType,
    required this.projectName,
    required this.selectedCountry,
    required this.selectedState,
    required this.selectedCity,
    required this.startDate,
    required this.endDate,
    required this.selectedCurrency,
    required this.budgetAmount,
    required this.selectedPriority,
    required this.assignmentType,
    required this.biddingDeadline,
    required this.projectDescription,
    required this.confirmInfo,
    required this.agreeTerms,
    required this.onConfirmInfoChanged,
    required this.onAgreeTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    String pTitle = projectType['title']!.replaceAll('\n', ' ');
    String pIcon = projectType['icon']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FBFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF309DAA).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFDED3)),
                ),
                child: Image.asset(
                  pIcon,
                  width: 32,
                  height: 32,
                  color: const Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pTitle • New Build',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2A8090),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Grid Summary
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildSummaryCard(
              'Location',
              '${selectedCity ?? ''}, ${selectedState ?? ''},\n${selectedCountry ?? ''}',
              'assets/images/map.png',
            ),
            _buildSummaryCard(
              'Timeline',
              '${startDate?.toString().substring(0, 10) ?? ''} to\n${endDate?.toString().substring(0, 10) ?? ''}',
              'assets/images/Calendar.png',
            ),
            _buildSummaryCard(
              'Budget',
              '$selectedCurrency$budgetAmount',
              'assets/images/bill-check.png',
            ),
            _buildSummaryCard(
              'Urgency',
              selectedPriority[0].toUpperCase() +
                  selectedPriority.substring(1).toLowerCase(),
              'assets/images/Target.png',
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Assignment Details Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assignment Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FBFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF309DAA)),
                      ),
                      child: Image.asset(
                        assignmentType == 'tender'
                            ? 'assets/images/construction-1.png'
                            : (assignmentType == 'direct'
                                  ? 'assets/images/group-1.png'
                                  : 'assets/images/Calendar-1.png'),
                        color: const Color(0xFF309DAA),
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignmentType == 'tender'
                                ? 'Public Tender (Deadline: ${biddingDeadline?.toString().substring(0, 10) ?? ''})'
                                : (assignmentType == 'direct'
                                      ? 'Assign Directly'
                                      : 'Decide Later'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Method: ${assignmentType?.toUpperCase() ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                projectDescription,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Agreements
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: confirmInfo,
                onChanged: onConfirmInfoChanged,
                activeColor: const Color(0xFF309DAA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'I confirm all information provided is accurate and reflect the true scope of the project.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: agreeTerms,
                onChanged: onAgreeTermsChanged,
                activeColor: const Color(0xFF309DAA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  children: const [
                    TextSpan(text: 'I agree to Converf\'s '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: Color(0xFF2A8090),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: ' regarding project quality monitoring.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String iconPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              iconPath,
              width: 16,
              height: 16,
              color: const Color(0xFF6B7280),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
