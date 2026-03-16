import 'package:flutter/material.dart';

class Step1BidAmount extends StatelessWidget {
  final TextEditingController bidAmountController;
  final String projectDuration;
  final String paymentPreference;
  final ValueChanged<String?> onDurationChanged;
  final ValueChanged<String?> onPaymentChanged;
  final VoidCallback onChanged;

  const Step1BidAmount({
    super.key,
    required this.bidAmountController,
    required this.projectDuration,
    required this.paymentPreference,
    required this.onDurationChanged,
    required this.onPaymentChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bid Amount & Timeline',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How much will you charge and how long will it take?',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your bid amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: bidAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '₦0.00',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '₦',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 8),
        Text(
          "Client's budget range: ₦45M - ₦55M",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        const Text(
          'Project Duration',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: projectDuration,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: ['1 Month', '3 Months', '6 Months', '12 Months']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onDurationChanged,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Client's budget range: ₦45M - ₦55M",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        const Text(
          'Payment Preference',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: paymentPreference,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: ['Upfront', 'Monthly Installments', 'On Completion']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onPaymentChanged,
            ),
          ),
        ),
      ],
    );
  }
}
