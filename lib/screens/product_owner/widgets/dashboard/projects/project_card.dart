import 'package:flutter/material.dart';

import '../../../../../features/projects/models/project.dart';
import '../../../../../core/utils/project_utils.dart';
import 'project_details_screen.dart';
import '../new_project_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final bool hasAlert;

  const ProjectCard({
    super.key,
    required this.project,
    this.hasAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (project.status == ProjectStatus.draft || project.currentStep < 5) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NewProjectModal(initialProject: project),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(projectId: project.id),
            ),
          );
        }
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (project.coverImage != null && project.coverImage!.isNotEmpty)
                    ? NetworkImage(project.coverImage!) as ImageProvider
                    : const AssetImage('assets/images/bg-1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              // If we have a real thumbnail, add an overlay to ensure text is readable
              decoration: BoxDecoration(
                color: (project.coverImage != null && project.coverImage!.isNotEmpty)
                    ? Colors.white.withValues(alpha: 0.65)
                    : Colors.transparent,
              ),
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
                                SvgPicture.asset(
                                  'assets/images/map.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF475467),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  project.formattedLocation,
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
                              project.status.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: project.status.color,
                              ),
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

                    // Alert or Spacer
                    if (hasAlert)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              child: SvgPicture.asset('assets/images/shield-warning.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(Color(0xFFD92D20), BlendMode.srcIn),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ball-in-court', style: TextStyle(fontSize: 12, color: Color(0xFF475467))),
                                SizedBox(height: 2),
                                Text('Project Owner', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828))),
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
                            SvgPicture.asset('assets/images/map.svg', colorFilter: const ColorFilter.mode(Color(0xFF0F973D), BlendMode.srcIn), width: 14, height: 14),
                            const SizedBox(width: 4),
                            const Text('Current Phase', style: TextStyle(color: Colors.white, fontSize: 13)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(
                                  value: 0.15,
                                  minHeight: 8,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF276572)),
                                ),
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
                            _buildBottomChip('assets/images/Calendar.svg', project.daysRemaining, flex: 1),
                            const SizedBox(width: 8),
                            _buildBottomChip('assets/images/team.svg', '--', flex: 1),
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
