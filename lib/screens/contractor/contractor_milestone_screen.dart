import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../features/projects/providers/milestone_providers.dart';
import '../../../features/projects/models/milestone.dart';
import 'package:intl/intl.dart';

class ContractorMilestoneScreen extends ConsumerStatefulWidget {
  const ContractorMilestoneScreen({super.key});

  @override
  ConsumerState<ContractorMilestoneScreen> createState() =>
      _ContractorMilestoneScreenState();
}

class _ContractorMilestoneScreenState
    extends ConsumerState<ContractorMilestoneScreen> {
  String _selectedFilter = 'All';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint('[ContractorMilestones] Auto-refreshing data...');
        ref.invalidate(allContractorMilestonesProvider);
        ref.invalidate(dashboardStatsProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final milestonesAsync = ref.watch(allContractorMilestonesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allContractorMilestonesProvider);
            return ref.read(allContractorMilestonesProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                /* milestonesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error loading milestones: $err')),
                  data: (milestones) => _buildStatsGrid(milestones),
                ),
                const SizedBox(height: 24),
                _buildFilterChips(),
                const SizedBox(height: 24),
                milestonesAsync.when(
                  loading: () => const SizedBox(),
                  error: (err, _) => const SizedBox(),
                  data: (milestones) {
                    final filtered = _applyFilter(milestones);
                    
                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No ${_selectedFilter.toLowerCase()} milestones found',
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: filtered.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildMilestoneCardFromData(m),
                      )).toList(),
                    );
                  },
                ), */
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 48,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Marketplace Features Coming Soon',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  List<MilestoneWithProject> _applyFilter(
    List<MilestoneWithProject> milestones,
  ) {
    switch (_selectedFilter) {
      case 'Overdue':
        return milestones
            .where(
              (m) =>
                  m.milestone.dueDate != null &&
                  m.milestone.dueDate!.isBefore(DateTime.now()) &&
                  !m.milestone.isApproved,
            )
            .toList();
      case 'This Week':
        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));
        return milestones
            .where(
              (m) =>
                  m.milestone.dueDate != null &&
                  m.milestone.dueDate!.isAfter(now) &&
                  m.milestone.dueDate!.isBefore(nextWeek),
            )
            .toList();
      default:
        return milestones;
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Marketplace',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: Color(0xFF101828)),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildStatsGrid(List<MilestoneWithProject> milestones) {
    final pending = milestones.where((m) => m.milestone.isPending).length;
    final overdue = milestones
        .where(
          (m) =>
              m.milestone.dueDate != null &&
              m.milestone.dueDate!.isBefore(DateTime.now()) &&
              !m.milestone.isApproved,
        )
        .length;
    final thisWeek = milestones.where((m) {
      if (m.milestone.dueDate == null) return false;
      final now = DateTime.now();
      return m.milestone.dueDate!.isAfter(now) &&
          m.milestone.dueDate!.isBefore(now.add(const Duration(days: 7)));
    }).length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Pending',
          pending.toString(),
          'assets/images/Construction-2.svg',
          const Color(0xFFF0FBFB),
          const Color(0xFF41B4CA),
        ),
        _buildStatCard(
          'Overdue',
          overdue.toString(),
          'assets/images/clock.svg',
          const Color(0xFFFFF6ED),
          const Color(0xFFF79009),
        ),
        _buildStatCard(
          'Due this week',
          thisWeek.toString(),
          'assets/images/Case.svg',
          const Color(0xFFF0FBFB),
          const Color(0xFF41B4CA),
        ),
        _buildStatCard(
          'Completed',
          milestones.where((m) => m.milestone.isApproved).length.toString(),
          'assets/images/check-circle.svg',
          const Color(0xFFFFF6ED),
          const Color(0xFFF79009),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String imagePath,
    Color innerColor,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DottedGridPainter())),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: innerColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: SvgPicture.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildFilterChips() {
    final filters = ['All', 'Overdue', 'This Week'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF276572)
                      : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildMilestoneCardFromData(MilestoneWithProject data) {
    final m = data.milestone;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    // Status color mapping
    Color statusColor = const Color(0xFFF79009);
    String statusLabel = m.status.toUpperCase();
    if (m.isApproved) {
      statusColor = const Color(0xFF12B76A);
    } else if (m.isDeclined) {
      statusColor = const Color(0xFFD92D20);
    }

    return _buildMilestoneCard(
      title: m.title,
      projectName: data.projectName,
      location: data.projectLocation ?? 'No location set',
      status: statusLabel,
      statusColor: statusColor,
      imagePath: data.projectImage ?? 'assets/images/bg-1.png',
      amount: currencyFormat.format(m.amount),
      dueDate: m.dueDate != null
          ? DateFormat('MMM dd, yyyy').format(m.dueDate!)
          : 'No due date',
      progress: m.isApproved ? 1.0 : (m.isDeclined ? 0.0 : 0.5),
      actionText: m.isPending ? 'View Project Details' : 'Details',
      onActionTap: () {
        // Navigation or Modal logic here
      },
    );
  }

  Widget _buildMilestoneCard({
    required String title,
    required String projectName,
    required String location,
    required String status,
    required Color statusColor,
    required String imagePath,
    required String amount,
    required String dueDate,
    required double progress,
    required String actionText,
    IconData? actionIcon,
    VoidCallback? onActionTap,
  }) {
    // Check if imagePath is a URL or asset
    final bool isNetworkImage = imagePath.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: isNetworkImage
                  ? NetworkImage(imagePath) as ImageProvider
                  : AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            projectName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white60,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amount',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          amount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Due Date',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          dueDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF41B4CA),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onActionTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF276572),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          actionText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (actionIcon != null) ...[
                          const SizedBox(width: 8),
                          Icon(actionIcon, size: 18),
                        ],
                        if (actionIcon == null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    const spacing = 12.0;
    const dotSize = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
