import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:converf/features/phases/models/phase_models.dart';
import 'package:converf/features/phases/providers/phase_providers.dart';
import 'package:converf/features/milestones/models/milestone_models.dart';
import 'package:converf/features/milestones/providers/milestone_providers.dart';

// ─── Status config identical to web `statusConfig` map ─────────────────────
class _StatusConfig {
  final String label;
  final Color numberBg;
  final Color numberText;
  final Color badgeBg;
  final Color badgeText;

  const _StatusConfig({
    required this.label,
    required this.numberBg,
    required this.numberText,
    required this.badgeBg,
    required this.badgeText,
  });
}

const _statusConfigs = <String, _StatusConfig>{
  'completed': _StatusConfig(
    label: 'Completed',
    numberBg: Color(0xFFE7F6EC),
    numberText: Color(0xFF15803D),
    badgeBg: Color(0xFFE7F6EC),
    badgeText: Color(0xFF036B26),
  ),
  'in_progress': _StatusConfig(
    label: 'In Progress',
    numberBg: Color(0xFFFEF6E7),
    numberText: Color(0xFFDD900D),
    badgeBg: Color(0xFFFEF6E7),
    badgeText: Color(0xFF865503),
  ),
  'overdue': _StatusConfig(
    label: 'Overdue',
    numberBg: Color(0xFFFEE4E2),
    numberText: Color(0xFFB42318),
    badgeBg: Color(0xFFFEE4E2),
    badgeText: Color(0xFFB42318),
  ),
  'pending': _StatusConfig(
    label: 'Pending',
    numberBg: Color(0xFFF0F2F5),
    numberText: Color(0xFF475367),
    badgeBg: Color(0xFFF0F2F5),
    badgeText: Color(0xFF475367),
  ),
};

_StatusConfig _getConfig(String status) =>
    _statusConfigs[status.toLowerCase()] ?? _statusConfigs['pending']!;

// ─── Main Modal ──────────────────────────────────────────────────────────────
class PhasesModal extends ConsumerStatefulWidget {
  final String projectId;
  const PhasesModal({super.key, required this.projectId});

  @override
  ConsumerState<PhasesModal> createState() => _PhasesModalState();
}

class _PhasesModalState extends ConsumerState<PhasesModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFEAECF0)),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PhasesTab(projectId: widget.projectId),
                  _MilestonesTab(projectId: widget.projectId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD0D5DD),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/routing.svg',
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.route, color: Color(0xFF276572)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Phases & Milestones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Color(0xFF667085)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFF101828),
        unselectedLabelColor: const Color(0xFF667085),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Phases'),
          Tab(text: 'Milestones'),
        ],
      ),
    );
  }
}

// ─── Phases Tab ──────────────────────────────────────────────────────────────
class _PhasesTab extends ConsumerWidget {
  final String projectId;
  const _PhasesTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phasesAsync = ref.watch(phasesProvider(projectId));

    return phasesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Error loading phases: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (response) {
        final phases = response.data;
        final completedCount = phases.where((p) => p.status == 'completed').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Construction Phases',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount of ${phases.length} phases completed',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: phases.isEmpty
                  ? _buildEmpty('No phases yet. The contractor will add phases once a schedule is submitted.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: phases.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _PhaseCard(phase: phases[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.route_outlined, size: 48, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF667085), height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Phase Card (mirrors web `article` card) ─────────────────────────────────
class _PhaseCard extends StatelessWidget {
  final Phase phase;
  const _PhaseCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(phase.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Order badge — mirroring the numbered div in the web card
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: config.numberBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${phase.order}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: config.numberText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name + status badge + date range
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        phase.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: config.badgeBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        config.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: config.badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${phase.startDate} – ${phase.endDate}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Milestones Tab ──────────────────────────────────────────────────────────
class _MilestonesTab extends ConsumerWidget {
  final String projectId;
  const _MilestonesTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesAsync = ref.watch(milestonesProvider(projectId));

    return milestonesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Error loading milestones: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (response) {
        final milestones = response.data;
        final completedCount = milestones.where((m) => m.isCompleted).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Milestones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount of ${milestones.length} milestones completed',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: milestones.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: milestones.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _MilestoneCard(milestone: milestones[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 48, color: Color(0xFF667085)),
            SizedBox(height: 16),
            Text(
              'No milestones yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Milestone Card ──────────────────────────────────────────────────────────
class _MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  const _MilestoneCard({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(milestone.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox-style status indicator
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: milestone.isCompleted ? const Color(0xFF276572) : Colors.white,
              border: Border.all(
                color: milestone.isCompleted ? const Color(0xFF276572) : const Color(0xFFD0D5DD),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: milestone.isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        milestone.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF101828),
                          decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFF667085),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: config.badgeBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        config.label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: config.badgeText),
                      ),
                    ),
                  ],
                ),
                if (milestone.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: milestone.isOverdue ? const Color(0xFFB42318) : const Color(0xFF667085),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due ${milestone.dueDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: milestone.isOverdue ? const Color(0xFFB42318) : const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ],
                if (milestone.description != null && milestone.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    milestone.description!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
