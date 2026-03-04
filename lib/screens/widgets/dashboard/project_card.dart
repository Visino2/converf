import 'package:flutter/material.dart';

import 'project_details_screen.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String location;
  final String status;
  final Color statusColor;
  final String budget;
  final String days;
  final String teamSize;
  final double progress;
  final bool hasAlert;

  const ProjectCard({
    super.key,
    required this.title,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.budget,
    required this.days,
    required this.teamSize,
    required this.progress,
    this.hasAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(
              title: title,
              location: location,
              status: status,
              statusColor: statusColor,
              heroImagePath:
                  'assets/images/lekki-complex.png', // Assuming all point here for the mock,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: hasAlert
              ? Border.all(color: const Color(0xFFE53935), width: 1.5)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 380,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg-1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(204),
                    Colors.transparent,
                    Colors.black.withAlpha(204),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/map.png',
                                    width: 16,
                                    height: 16,
                                    color: const Color(0xFF475467),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF475467),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                      ],
                    ),

                    // Middle / Alert Section
                    if (hasAlert)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFEE4E2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE4E2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/shield-warning.png',
                                width: 20,
                                height: 20,
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
                                    fontSize: 12,
                                    color: Color(0xFF475467),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Project Owner',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF101828),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),

                    // Bottom Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/routing.png',
                              width: 16,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Current Phase',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF276572),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBottomChip(
                              'assets/images/bill-list.png',
                              budget,
                              flex: 2,
                            ),
                            const SizedBox(width: 8),
                            _buildBottomChip(
                              'assets/images/Calendar.png',
                              days,
                              flex: 1,
                            ),
                            const SizedBox(width: 8),
                            _buildBottomChip(
                              'assets/images/team.png',
                              teamSize,
                              flex: 1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ), // This closes the newly added GestureDetector(child: Container(...
    );
  }

  Widget _buildBottomChip(String iconPath, String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 16,
              height: 16,
              color: const Color(0xFF475467),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
