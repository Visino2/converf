import 'package:flutter/material.dart';

class StepSuccessScreen extends StatelessWidget {
  final String projectName;
  final VoidCallback onGoToDashboard;

  const StepSuccessScreen({
    super.key,
    required this.projectName,
    required this.onGoToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/colourful.png',
              height: 150,
              fit: BoxFit.cover,
            ),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F6EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/check.png',
                  width: 56,
                  height: 56,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Project Created Successfully!',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF171717),
            height: 1.2,
            letterSpacing: -0.48,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Your project "'),
              TextSpan(
                text: projectName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF276572),
                ),
              ),
              const TextSpan(text: '" is ready\nfor management.'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF2A8090),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Invite Team Members',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add contractors and team members',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Invite Team',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A8090),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF2A8090),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onGoToDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A8090),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Go to Project Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/images/construction-1.png',
                  color: Colors.white,
                  width: 18,
                  height: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
