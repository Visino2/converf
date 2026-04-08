import 'package:converf/features/billing/models/billing_models.dart';
import 'package:flutter/material.dart';

class UsageSection extends StatelessWidget {
  final BillingLimits limits;

  const UsageSection({super.key, required this.limits});

  @override
  Widget build(BuildContext context) {
    final storage = limits.storage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usage & Limits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          _ProgressBar(
            label: 'Total Storage',
            used: '${storage.usedGb.toStringAsFixed(1)} GB',
            total: '${storage.allowedGb.toStringAsFixed(0)} GB',
            percentage: storage.usagePercentage,
            icon: Icons.cloud_outlined,
          ),
          const SizedBox(height: 20),
          _ProgressBar(
            label: 'Team Members',
            used: '${limits.teamMembers ?? 0}',
            total: '${limits.maxProjects ?? '∞'}',
            percentage: (limits.teamMembers ?? 0) / (limits.maxProjects ?? 1).toDouble(),
            icon: Icons.people_outline,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final String used;
  final String total;
  final double percentage;
  final IconData icon;

  const _ProgressBar({
    required this.label,
    required this.used,
    required this.total,
    required this.percentage,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF667085)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
            const Spacer(),
            Text(
              '$used / $total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFF2F4F7),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.9 ? const Color(0xFFD92D20) : const Color(0xFF276572),
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
