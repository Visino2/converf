import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/ai_credits/providers/ai_credits_provider.dart';
import '../../../../../features/projects/providers/project_advisory_providers.dart';

/// Project Advisory / AI Insights panel for the Product Owner.
/// Provides contextual project health indicators and AI driven suggestions.
class ProjectAdvisoryCard extends ConsumerWidget {
  final String projectId;
  const ProjectAdvisoryCard({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiCreditsState = ref.watch(aiCreditsProvider);
    final advisoryState = ref.watch(projectAdvisoryProvider(projectId));

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
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF276572),
                    BlendMode.srcIn,
                  ),
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF276572),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Advisory',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Latest AI-assisted guidance based on project health signals.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: advisoryState.isLoading 
                  ? null 
                  : () => ref.invalidate(projectAdvisoryProvider(projectId)),
                icon: advisoryState.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh, size: 20, color: Color(0xFF667085)),
                tooltip: 'Regenerate Advisory',
              ),
            ],
          ),
          const SizedBox(height: 16),
          aiCreditsState.when(
            loading: () => _buildCreditsBanner(
              label: 'AI credits',
              value: 'Loading...',
              icon: Icons.hourglass_top_rounded,
              backgroundColor: const Color(0xFFF8F9FC),
              iconColor: const Color(0xFF667085),
              textColor: const Color(0xFF475467),
            ),
            error: (error, _) => _buildCreditsBanner(
              label: 'AI credits unavailable',
              value: 'Try again later',
              icon: Icons.error_outline,
              backgroundColor: const Color(0xFFFFF4ED),
              iconColor: const Color(0xFFB54708),
              textColor: const Color(0xFF93370D),
            ),
            data: (balance) => _buildCreditsBanner(
              label: 'AI credits available',
              value: balance.displayValue,
              icon: Icons.auto_awesome,
              backgroundColor: const Color(0xFFF0F9FF),
              iconColor: const Color(0xFF276572),
              textColor: const Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 24),

          // AI Score Banner
          advisoryState.when(
            loading: () => _buildScoreBanner('...', 'Calculating health score...'),
            error: (err, _) => _buildScoreBanner('N/A', 'Error calculating score'),
            data: (response) {
              String message = response.healthMessage;
              if (message.isEmpty) {
                message = 'Your project health is being monitored.';
              }

              return _buildScoreBanner(response.healthScore.toString(), message);
            },
          ),
          const SizedBox(height: 24),

          // Advisory Cards
          const Text(
            'Active Advisories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          
          advisoryState.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('No active advisories found yet.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ),
            data: (response) {
              final advisories = response.advisories;
              
              if (advisories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.grey[300], size: 40),
                        const SizedBox(height: 8),
                        const Text(
                          'No critical advisories at this time.',
                          style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: advisories.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _advisoryCard(
                    item.type.icon,
                    item.title,
                    item.body,
                    item.type.bgColor,
                    item.type.color,
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Tips
          const Text(
            'Project Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          _tipRow(
            'Keep your Ball-in-Court actions resolved within 48 hours to maintain project momentum.',
          ),
          _tipRow(
            'Use Field Inspections to document site conditions and quality milestones.',
          ),
          _tipRow(
            'Review Daily Reports regularly to stay informed about on-site progress.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScoreBanner(String score, String message) {
    return Container(
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
                const Text(
                  'Project Health Score',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  score,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
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
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _advisoryCard(
    IconData icon,
    String title,
    String body,
    Color bg,
    Color color,
  ) {
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                    height: 1.4,
                  ),
                ),
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
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFFF59E0B),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475467),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsBanner({
    required String label,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
