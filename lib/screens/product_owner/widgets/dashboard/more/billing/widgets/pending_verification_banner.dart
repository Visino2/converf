import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingVerificationBanner extends StatelessWidget {
  final String reference;
  final AsyncValue<void> actionState;
  final VoidCallback onVerify;

  const PendingVerificationBanner({
    super.key,
    required this.reference,
    required this.actionState,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF276572)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Payment is still being confirmed. If you already completed checkout, refresh your plan now.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF276572),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: actionState.isLoading ? null : onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: actionState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Refresh Plan', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
