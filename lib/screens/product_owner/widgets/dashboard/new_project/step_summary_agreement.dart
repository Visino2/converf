import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';

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
            border: Border.all(color: const Color(0xFF309DAA).withValues(alpha: 0.3)),
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
                child: pIcon.endsWith('.svg')
                    ? SvgPicture.asset(
                        pIcon,
                        width: 32,
                        height: 32,
                        colorFilter: const ColorFilter.mode(Color(0xFFEA580C), BlendMode.srcIn),
                      )
                    : Image.asset(
                        filterQuality: FilterQuality.high,
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
              _formatLocation(),
              'assets/images/map.svg',
            ),
            _buildSummaryCard(
              'Timeline',
              _formatDateRange(startDate, endDate),
              'assets/images/Calendar.svg',
            ),
            _buildSummaryCard(
              'Budget',
              _formatBudget(),
              'assets/images/bill-check.svg',
            ),
            _buildSummaryCard(
              'Urgency',
              _formatPriority(),
              'assets/images/Target.svg',
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
                      child: SvgPicture.asset(
                        assignmentType == 'tender'
                            ? 'assets/images/construction-1.svg'
                            : (assignmentType == 'direct'
                                ? 'assets/images/group-1.svg'
                                : 'assets/images/Calendar-1.svg'),
                        colorFilter: const ColorFilter.mode(Color(0xFF309DAA), BlendMode.srcIn),
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
                            _assignmentTitle(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Method: ${_assignmentMethodLabel()}',
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
                  children: [
                    const TextSpan(text: 'I agree to Converf\'s '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: const TextStyle(
                        color: Color(0xFF2A8090),
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Navigate to terms and conditions
                        },
                    ),
                    const TextSpan(text: ' regarding project quality monitoring.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatLocation() {
    final parts = [selectedCity, selectedState, selectedCountry]
        .whereType<String>()
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Not specified' : parts.join(', ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'TBD';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    return '${_formatDate(start)} to\n${_formatDate(end)}';
  }

  String _formatBudget() {
    final cleaned = budgetAmount.replaceAll(',', '').replaceAll(' ', '');
    final value = num.tryParse(cleaned);
    final formatted = value != null ? NumberFormat('#,##0').format(value) : budgetAmount;
    return '$selectedCurrency $formatted'.trim();
  }

  String _formatPriority() {
    final value = selectedPriority.trim();
    if (value.isEmpty) return 'Not set';
    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }

  String _assignmentTitle() {
    if (assignmentType == 'tender') {
      final deadlineText = biddingDeadline != null ? ' (Deadline: ${_formatDate(biddingDeadline)})' : '';
      return 'Public Tender$deadlineText';
    }
    if (assignmentType == 'direct') return 'Assign Directly';
    return 'Decide Later';
  }

  String _assignmentMethodLabel() {
    return (assignmentType ?? 'TBD').toUpperCase();
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: iconPath.endsWith('.svg')
                ? SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Color(0xFFEA580C), BlendMode.srcIn),
                  )
                : Image.asset(
                    filterQuality: FilterQuality.high,
                    iconPath,
                    width: 24,
                    height: 24,
                    color: const Color(0xFFEA580C),
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
