import 'package:flutter/material.dart';

import '../overview_modal.dart';
import '../field_inspections_modal.dart';
import '../phases_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/projects/providers/project_providers.dart';
import '../../../../../core/utils/project_utils.dart';
import '../../../../../features/projects/models/project.dart';
import 'bids_modal.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
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
        title: const Text(
          'Project Details',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: ref.watch(projectDetailsProvider(widget.projectId)).when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
        error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
        data: (projectData) {
          final project = projectData.data;

          if (project == null) {
            return const Scaffold(
              body: Center(child: Text('Project not found')),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    project.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/images/map.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Color(0xFF12B76A), BlendMode.srcIn)),
                          const SizedBox(width: 4),
                          Text(project.formattedLocation, style: const TextStyle(fontSize: 14, color: Color(0xFF475467))),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFEF0C7), borderRadius: BorderRadius.circular(12)),
                            child: Text(project.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: project.status.color)),
                          ),
                          const SizedBox(width: 8),
                          if (project.constructionType.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12)),
                              child: Text(project.constructionType.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF344054))),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/lekki-complex.png', // Temporary hardcoded since we need to upload project image
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFEAECF0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('Update Thumbnail', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (!_isApproved) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFAEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFEDF89)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF0C7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SvgPicture.asset('assets/images/shield-warning.svg', width: 24, height: 24),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ball-in-court', style: TextStyle(fontSize: 14, color: Color(0xFF475467))),
                                  SizedBox(height: 2),
                                  Text('Project Owner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('Confirm roofing tile color and material', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFDC6803))),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _isApproved = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF276572),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Approve', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                      SizedBox(width: 8),
                                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD92D20),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  ),
                                  child: const Text('Decline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // AI Score Placeholder
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('QUALITY SCORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF475467))),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF12B76A), shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('92%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.0, color: Color(0xFF101828))),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFD1FADF), borderRadius: BorderRadius.circular(16)),
                                child: const Text('EXCELLENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF039855))),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Converf AI analyzed quality based on 145 data points', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF98A2B3))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFEAECF0)), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('OVERALL PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF475467))),
                              const SizedBox(height: 8),
                              const Text('68%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.0, color: Color(0xFF101828))),
                              const SizedBox(height: 12),
                              Stack(
                                children: [
                                  Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(3))),
                                  FractionallySizedBox(
                                    widthFactor: 0.68,
                                    child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFF12B76A), borderRadius: BorderRadius.circular(3))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Financials
                      Expanded(
                        child: ref.watch(projectFinancialsProvider(widget.projectId)).when(
                          loading: () => const Center(child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: Color(0xFF276572)),
                          )),
                          error: (error, _) => Container(
                            padding: const EdgeInsets.all(16),
                            child: const Text('Finances errored', style: TextStyle(color: Colors.red)),
                          ),
                          data: (financials) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFEAECF0)), borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BUDGET UTILIZED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF475467))),
                                  const SizedBox(height: 8),
                                  Text('${financials.budgetUtilizedPercentage}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.0, color: Color(0xFF101828))),
                                  const SizedBox(height: 12),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        text: '${financials.formattedEarnedValue} / ',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF98A2B3)),
                                        children: [TextSpan(text: financials.formattedContractValue, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF344054)))],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _buildTabItem('assets/images/home-2.svg', 'Overview', isActive: true, onTapped: () {
                          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const OverviewModal());
                        })),
                        const SizedBox(width: 4),
                        Expanded(flex: 3, child: _buildTabItem('assets/images/camera-1.svg', 'Field Inspections', isActive: false, onTapped: () {
                          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const FieldInspectionsModal());
                        })),
                        const SizedBox(width: 4),
                        Expanded(flex: 2, child: _buildTabItem('assets/images/routing.svg', 'Phases', isActive: false, onTapped: () {
                          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const PhasesModal());
                        })),
                        const SizedBox(width: 4),
                        Expanded(flex: 2, child: _buildTabItem('assets/images/projects.svg', 'Bids', isActive: false, onTapped: () {
                          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => BidsModal(projectId: widget.projectId));
                        })),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF276572),
          unselectedItemColor: Colors.black87,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) Navigator.popUntil(context, (route) => route.isFirst);
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/home.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/home.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/projects.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/projects.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/team.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/team.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/more.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/more.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String iconPath, String label, {required bool isActive, required VoidCallback onTapped}) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF9FAFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconPath.endsWith('.svg')
                ? SvgPicture.asset(
                    iconPath,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                        isActive ? const Color(0xFF276572) : const Color(0xFF667085),
                        BlendMode.srcIn),
                  )
                : Image.asset(
                    iconPath,
                    width: 18,
                    height: 18,
                    color: isActive ? const Color(0xFF276572) : const Color(0xFF667085),
                  ),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: isActive ? const Color(0xFF101828) : const Color(0xFF667085))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
