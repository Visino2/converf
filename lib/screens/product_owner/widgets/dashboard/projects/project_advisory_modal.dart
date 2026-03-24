import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Project Advisory / AI Insights panel for the Product Owner.
/// Provides contextual project health indicators and AI driven suggestions.
class ProjectAdvisoryCard extends StatelessWidget {
  final String projectId;
  const ProjectAdvisoryCard({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: SvgPicture.asset(
                  'assets/images/shield-warning.svg',
                  width: 20, height: 20,
                  colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                  errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: Color(0xFF276572), size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project Advisory',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                    SizedBox(height: 2),
                    Text('Latest AI-assisted guidance based on project health signals.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

            // AI Score Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF276572), Color(0xFF1D4E5A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Project Health Score', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 4),
                        const Text('N/A', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text(
                          'Converf AI is still analyzing your project data.',
                          style: TextStyle(fontSize: 11, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Advisory Cards
            const Text('Active Advisories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
            const SizedBox(height: 12),
            _advisoryCard(
              Icons.schedule_outlined,
              'Schedule Review Recommended',
              'No approved schedule found. Consider creating and reviewing a formal project schedule with the contractor.',
              const Color(0xFFFFFAEB),
              const Color(0xFFB54708),
            ),
            const SizedBox(height: 10),
            _advisoryCard(
              Icons.assignment_outlined,
              'Pending Bid Proposals',
              'Review and respond to contractor proposals in the Bids tab to keep the project moving forward.',
              const Color(0xFFF0F9FF),
              const Color(0xFF276572),
            ),
            const SizedBox(height: 10),
            _advisoryCard(
              Icons.verified_outlined,
              'Quality Tracking Not Yet Active',
              'Approve an inspection report to activate Converf AI quality scoring for your project.',
              const Color(0xFFF9FAFB),
              const Color(0xFF667085),
            ),
            const SizedBox(height: 24),

            // Tips
            const Text('Project Tips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
            const SizedBox(height: 12),
            _tipRow('Keep your Ball-in-Court actions resolved within 48 hours to maintain project momentum.'),
            _tipRow('Use Field Inspections to document site conditions and quality milestones.'),
            _tipRow('Review Daily Reports regularly to stay informed about on-site progress.'),
            const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _advisoryCard(IconData icon, String title, String body, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 12, color: Color(0xFF667085), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF475467), height: 1.4)),
          ),
        ],
      ),
    );
  }
}
