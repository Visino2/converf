import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/reinspection_modals.dart';
import 'widgets/qaqc_audit_modal.dart';

class ContractorMilestoneScreen extends StatefulWidget {
  const ContractorMilestoneScreen({super.key});

  @override
  State<ContractorMilestoneScreen> createState() => _ContractorMilestoneScreenState();
}

class _ContractorMilestoneScreenState extends State<ContractorMilestoneScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildFilterChips(),
              const SizedBox(height: 24),
              _buildMilestoneCard(
                title: 'Lekki Residential Complex',
                location: 'Lekki Phase 1, Lagos',
                status: 'AT RISK',
                statusColor: const Color(0xFFF79009),
                imagePath: 'assets/images/bg-1.png',
                progress: 0.65,
                inspectionRequired: true,
                qualityScore: '94%',
                isQualityGood: true,
                actionText: 'Complete Milestone',
                actionIcon: Icons.chevron_right,
                onActionTap: () => showQualityVerificationFailedModal(context),
              ),
              const SizedBox(height: 24),
              _buildMilestoneCard(
                title: 'Lekki Residential Complex',
                location: 'Lekki Phase 1, Lagos',
                status: 'AT RISK',
                statusColor: const Color(0xFFF79009),
                imagePath: 'assets/images/bg-1.png',
                progress: 0.65,
                inspectionRequired: true,
                qualityScore: '64%',
                isQualityGood: false,
                actionText: 'Request Re-inspect (N50,000)',
                isErrorAction: true,
                onActionTap: () => showQualityVerificationFailedModal(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Milestones & Tasks',
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

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('Pending Tasks', '2', 'assets/images/Construction-2.svg', const Color(0xFFF0FBFB), const Color(0xFF41B4CA)),
        _buildStatCard('Overdue', '8', 'assets/images/clock.svg', const Color(0xFFFFF6ED), const Color(0xFFF79009)),
        _buildStatCard('QA Scheduled', '8', 'assets/images/check-circle.svg', const Color(0xFFFFF6ED), const Color(0xFFF79009)),
        _buildStatCard('Due this week', '₦1.3B', 'assets/images/Case.svg', const Color(0xFFF0FBFB), const Color(0xFF41B4CA)),
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
          Positioned.fill(
            child: CustomPaint(
              painter: _DottedGridPainter(),
            ),
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF276572) : const Color(0xFFF2F4F7),
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

  Widget _buildMilestoneCard({
    required String title,
    required String location,
    required String status,
    required Color statusColor,
    required String imagePath,
    required double progress,
    required bool inspectionRequired,
    required String qualityScore,
    required bool isQualityGood,
    required String actionText,
    IconData? actionIcon,
    bool isErrorAction = false,
    VoidCallback? onActionTap,
  }) {
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
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                              color: Color(0xFF101828),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF475467), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: const TextStyle(color: Color(0xFF475467), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFAEB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.circle, color: Color(0xFF12B76A), size: 12),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),
                
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF276572),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                GestureDetector(
                  onTap: () => showQaQcAuditModal(context),
                  child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEAECF0)),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DottedGridPainter(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('QA/QC Inspection Required', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF276572),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Completed', style: TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFEAECF0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(isQualityGood ? 'Quality Score: ' : 'Fail Score : ', 
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                                        Text(qualityScore, 
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, 
                                            color: isQualityGood ? const Color(0xFF12B76A) : const Color(0xFFD92D20))),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFAEB),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFEDF89)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.info_outline, size: 16, color: Color(0xFFB4543E)),
                                        SizedBox(width: 4),
                                        Text('1 Issue to rectify', style: TextStyle(fontSize: 10, color: Color(0xFFB4543E))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onActionTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isErrorAction ? const Color(0xFFD92D20) : const Color(0xFF276572),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          actionText,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (actionIcon != null) ...[
                          const SizedBox(width: 8),
                          Icon(actionIcon, color: Colors.white),
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
