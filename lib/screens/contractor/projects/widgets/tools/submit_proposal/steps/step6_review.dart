import 'package:flutter/material.dart';
import '../widgets/dashed_button.dart';

class Step6Review extends StatelessWidget {
  final String bidAmount;
  final String projectDuration;
  final bool confirmAccurate;
  final bool agreeToTerms;
  final ValueChanged<bool?> onConfirmChanged;
  final ValueChanged<bool?> onAgreeChanged;

  const Step6Review({
    super.key,
    required this.bidAmount,
    required this.projectDuration,
    required this.confirmAccurate,
    required this.agreeToTerms,
    required this.onConfirmChanged,
    required this.onAgreeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select similar past projects to strengthen your bid.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF276572),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD8F3F5), width: 1),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/images/new-bid.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Final Bid Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        bidAmount.isEmpty ? '₦45,000,000' : '₦$bidAmount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ Total Budget',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            projectDuration,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Icon(Icons.track_changes, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            '92% Match',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: confirmAccurate,
              onChanged: onConfirmChanged,
              activeColor: const Color(0xFF276572),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            const Expanded(
              child: Text(
                'I confirm that all provided information is accurate and I have the capacity to deliver the project as specified.',
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: agreeToTerms,
              onChanged: onAgreeChanged,
              activeColor: const Color(0xFF276572),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            const Expanded(
              child: Text(
                "I agree to Converf's Bidding Terms & Conditions and understand this proposal is binding.",
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        DashedButton(
          iconPath: 'assets/images/upload-1.svg',
          label: 'Upload Additional Document',
          onTap: () {},
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            border: Border.all(color: const Color(0xFFFED7AA)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEA580C), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your profile verification score (85%) is high enough for this bid. Increasing it to 100% can boost your win probability by up to 15%.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
