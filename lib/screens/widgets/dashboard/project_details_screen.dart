import 'package:flutter/material.dart';

import 'overview_modal.dart';
import 'field_inspections_modal.dart';
import 'phases_modal.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String title;
  final String location;
  final String status;
  final Color statusColor;
  final String heroImagePath;

  const ProjectDetailsScreen({
    super.key,
    required this.title,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.heroImagePath,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _isApproved = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Location & Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/map.png',
                        width: 16,
                        height: 16,
                        color: const Color(0xFF12B76A),
                      ), // Green pin based on the image
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475467),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF0C7), // orange tint bg
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget
                                .statusColor, // usually orange/red depending on the card
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7), // grey bg
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'RESIDENTIAL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF344054),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.heroImagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(50)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Update Thumbnail',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Conditional Ball-in-court Action Card
              if (!_isApproved) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFbf9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFEDF89),
                    ), // orange-ish border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE4E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/shield-warning.png',
                              width: 24,
                              height: 24,
                              color: const Color(0xFFD92D20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ball-in-court',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF475467),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Project Owner',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Confirm roofing tile color and material',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFDC6803), // Orange text
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isApproved = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF276572,
                                ), // Teal color
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Approve',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Logic for decline could go here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFD92D20,
                                ), // Red color
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                'Decline',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quality Score Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3), // Light green bg
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'QUALITY SCORE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Color(0xFF475467),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF12B76A), // Green dot
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '92%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FADF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'EXCELLENT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF039855),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Converf AI analyzed quality based on 145 data points',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Progress and Budget Cards Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEAECF0)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OVERALL PROGRESS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Color(0xFF475467),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '68%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F7),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: 0.68,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF12B76A,
                                    ), // Green progress
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEAECF0)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BUDGET UTILIZED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Color(0xFF475467),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '35%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: const TextSpan(
                              text: '₦32,000,000 / ',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF98A2B3),
                              ),
                              children: [
                                TextSpan(
                                  text: '₦45,000,000',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF344054),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tabs
              Container(
                width: 361,
                height: 57,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTabItem(
                        'assets/images/home-2.png',
                        'Overview',
                        isActive: true,
                        onTapped: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const OverviewModal(),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildTabItem(
                        'assets/images/camera-1.png',
                        'Field Inspections',
                        isActive: false,
                        onTapped: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const FieldInspectionsModal(),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildTabItem(
                        'assets/images/routing.png',
                        'Phases',
                        isActive: false,
                        onTapped: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const PhasesModal(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF276572),
          unselectedItemColor: Colors.black87,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          currentIndex: 1, // Projects is index 1
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home.png',
                width: 24,
                height: 24,
                color: Colors.black87,
              ),
              activeIcon: Image.asset(
                'assets/images/home.png',
                width: 24,
                height: 24,
                color: const Color(0xFF276572),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/projects.png',
                width: 24,
                height: 24,
                color: Colors.black87,
              ),
              activeIcon: Image.asset(
                'assets/images/projects.png',
                width: 24,
                height: 24,
                color: const Color(0xFF276572),
              ),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/team.png',
                width: 24,
                height: 24,
                color: Colors.black87,
              ),
              activeIcon: Image.asset(
                'assets/images/team.png',
                width: 24,
                height: 24,
                color: const Color(0xFF276572),
              ),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/more.png',
                width: 24,
                height: 24,
                color: Colors.black87,
              ),
              activeIcon: Image.asset(
                'assets/images/more.png',
                width: 24,
                height: 24,
                color: const Color(0xFF276572),
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    String iconPath,
    String label, {
    required bool isActive,
    required VoidCallback onTapped,
  }) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF9FAFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 22,
              height: 22,
              color: isActive
                  ? const Color(0xFF276572)
                  : const Color(0xFF667085),
            ),
            if (isActive) const SizedBox(width: 8),
            if (isActive)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
