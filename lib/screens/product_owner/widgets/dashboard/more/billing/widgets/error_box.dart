import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorBox({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB42318)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB42318),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB42318),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Try again'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
