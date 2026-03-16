import 'package:flutter/material.dart';

import '../../../../features/projects/models/project.dart';
import '../../../../core/utils/project_utils.dart';
import 'contractor_project_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContractorProjectCard extends StatelessWidget {
  final Project project;
  final bool hasAlert;

  const ContractorProjectCard({
    super.key,
    required this.project,
    this.hasAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContractorProjectDetailsScreen(projectId: project.id),
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
                                project.title,
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
                                  SvgPicture.asset('assets/images/map.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: const ColorFilter.mode(Color(0xFF475467), BlendMode.srcIn),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    project.formattedLocation,
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF475467)),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                project.status.label,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: project.status.color),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF12B76A),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Bottom Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/map.svg', colorFilter: const ColorFilter.mode(Color(0xFF0F973D), BlendMode.srcIn), width: 14, height: 14),
                            const SizedBox(width: 4),
                            const Text('Current Phase', style: TextStyle(color: Colors.white, fontSize: 13)),
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
                                    widthFactor: 0.15, 
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
                            _buildBottomChip('assets/images/bill-list.svg', project.formattedBudget, flex: 2),
                            const SizedBox(width: 8),
                            _buildBottomChip('assets/images/routing.svg', 'Phase 1', flex: 2), // Hardcoded phase name until endpoint

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
    );
  }

  Widget _buildBottomChip(String iconPath, String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 16, height: 16, colorFilter: const ColorFilter.mode(Color(0xFF475467), BlendMode.srcIn)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
