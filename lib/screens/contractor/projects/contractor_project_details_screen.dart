import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../product_owner/widgets/dashboard/overview_modal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/projects/providers/project_providers.dart';
import '../../../../core/utils/project_utils.dart';
import '../../../../features/projects/models/project.dart';

class ContractorProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ContractorProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ContractorProjectDetailsScreen> createState() => _ContractorProjectDetailsScreenState();
}

class _ContractorProjectDetailsScreenState extends ConsumerState<ContractorProjectDetailsScreen> {
  int _selectedTabIndex = 0;

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

                  // Location & Status badges
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

                  // Hero image with Update Thumbnail button
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/lekki-complex.png', // Temporary placeholder
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
                          child: Row(
                            children: [
                              SvgPicture.asset('assets/images/camera.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Color(0xFF344054), BlendMode.srcIn)),
                              const SizedBox(width: 8),
                              const Text('Update Thumbnail', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

              // Action buttons: Update Progress & Submit Milestone
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD0D5DD)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(
                            child: Text('Update Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054)), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset('assets/images/camera.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Color(0xFF344054), BlendMode.srcIn)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF276572),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(
                            child: Text('Submit Milestone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset('assets/images/Target.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Client Interface section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Client Interface', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                        Row(
                          children: [
                            ClipOval(
                              child: Image.asset('assets/images/chinedu.png', width: 36, height: 36, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Chinedu Okafor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828))),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFDB022), size: 14),
                                    const SizedBox(width: 2),
                                    const Text('4.9', style: TextStyle(fontSize: 12, color: Color(0xFF475467))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF276572),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/images/message.svg', width: 18, height: 18, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                            const SizedBox(width: 8),
                            const Text('Message Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Current Status section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAECF0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline, size: 20, color: Color(0xFF344054)),
                        ),
                        const SizedBox(width: 12),
                        const Text('Current Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      project.description.isNotEmpty ? project.description : 'No description provided.',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF475467), height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD0D5DD)),
                          ),
                          child: const Text('8/12 Phases Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF344054))),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD0D5DD)),
                          ),
                          child: const Text('92% Quality Score', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF344054))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ball-in-court card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFEDF89)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE4E2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.error_outline, size: 20, color: Color(0xFFD92D20)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ball-in-court', style: TextStyle(fontSize: 14, color: Color(0xFF475467))),
                                  const SizedBox(height: 2),
                                  const Text('You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF276572),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Address Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab section: Overview, Tasks, Documents, Team, Financial
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabItem('assets/images/home-2.svg', 'Overview', 0, () => _showOverviewModal()),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/Checklist.svg', 'Tasks', 1, () => _showTaskListModal()),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/document-1.svg', 'Documents', 2, () => _showDocumentsModal()),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/group.svg', 'Team', 3, () => _showTeamModal()),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/financial.svg', 'Financial', 4, () => _showFinancialModal()),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }),
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
              icon: SvgPicture.asset('assets/images/target-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/target-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Milestone',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/case-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/case-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Tools',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String iconPath, String label, int index, VoidCallback onTapped) {
    bool isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        onTapped();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF9FAFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                isActive ? const Color(0xFF276572) : const Color(0xFF667085),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF101828) : const Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modal launchers ──

  void _showOverviewModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OverviewModal(),
    );
  }

  void _showTaskListModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskListModal(),
    );
  }

  void _showDocumentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DocumentsModal(),
    );
  }

  void _showTeamModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TeamModal(),
    );
  }

  void _showFinancialModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FinancialModal(),
    );
  }
}

// ── Task List Modal ──
class _TaskListModal extends StatefulWidget {
  @override
  State<_TaskListModal> createState() => _TaskListModalState();
}

class _TaskListModalState extends State<_TaskListModal> {
  final List<Map<String, dynamic>> _tasks = [
    {'deadline': 'Feb 12, 2026', 'assigned': 'Olumide Oke', 'title': 'Soil test results for block B foundation', 'completed': false},
    {'deadline': 'Feb 14, 2026', 'assigned': 'Seyi (Electrician)', 'title': 'Lagos STate building control agency', 'completed': false},
    {'deadline': 'Feb 14, 2026', 'assigned': 'Seyi (Electrician)', 'title': 'Lagos STate building control agency', 'completed': true},
  ];

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['completed'] = !(_tasks[index]['completed'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/images/Checklist.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
                    const SizedBox(width: 12),
                    const Text('Task List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...List.generate(_tasks.length, (index) {
              final task = _tasks[index];
              final bool isCompleted = task['completed'] as bool;
              return GestureDetector(
                onTap: () => _toggleTask(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isCompleted ? const Color(0xFF276572) : const Color(0xFFEAECF0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFF276572) : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: isCompleted ? const Color(0xFF276572) : const Color(0xFFD0D5DD), width: 2),
                        ),
                        child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deadline: ${task['deadline']} • Assigned: ${task['assigned']}', style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                            const SizedBox(height: 8),
                            Text(task['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF101828),
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276572),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('New Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Documents Modal ──
class _DocumentsModal extends StatelessWidget {
  final List<Map<String, String>> documents = const [
    {'name': 'Roofing_Plan_V1', 'size': '2.5MB'},
    {'name': 'Lekki_Permit_App', 'size': '2.5MB'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/images/document-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
                    const SizedBox(width: 12),
                    const Text('Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Project Documents', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
            const SizedBox(height: 8),
            const Text('2 files stored securely', style: TextStyle(fontSize: 16, color: Color(0xFF667085))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276572),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/upload-1.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    const SizedBox(width: 8),
                    const Text('Upload Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: const Color(0xFFF9FAFB),
              child: const Row(
                children: [
                  Expanded(child: Text('Document Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                  Text('Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467))),
                  SizedBox(width: 16),
                ],
              ),
            ),
            ...documents.map((doc) => Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SvgPicture.asset('assets/images/document.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(Color(0xFF039855), BlendMode.srcIn)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(doc['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF101828))),
                  ),
                  Text(doc['size']!, style: const TextStyle(fontSize: 14, color: Color(0xFF475467))),
                  const SizedBox(width: 16),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Team Modal ──
class _TeamModal extends StatelessWidget {
  final List<Map<String, String>> teamMembers = const [
    {'name': 'Olamide Akintan', 'role': 'Project Manager', 'avatar': 'assets/images/olamide.png'},
    {'name': 'Alison David', 'role': 'Site Engineer', 'avatar': 'assets/images/alison.png'},
    {'name': 'Megan Willow', 'role': 'Structural Engineer', 'avatar': 'assets/images/megan.png'},
    {'name': 'Janelle Levi', 'role': 'Architect', 'avatar': 'assets/images/janelle.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/images/group.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
                    const SizedBox(width: 12),
                    const Text('Team', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: const Color(0xFFF9FAFB),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                  const Expanded(child: Text('Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                ],
              ),
            ),
            ...teamMembers.map((member) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(member['avatar']!, width: 40, height: 40, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 40, height: 40,
                              decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: Color(0xFF98A2B3)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(child: Text(member['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828)))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(member['role']!, style: const TextStyle(fontSize: 14, color: Color(0xFF475467))),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Financial Modal ──
class _FinancialModal extends StatelessWidget {
  final List<Map<String, String>> payments = const [
    {'amount': '₦4.2M', 'status': 'Pending', 'date': '4/21/12'},
    {'amount': '₦4.2M', 'status': 'Paid', 'date': '4/4/18'},
    {'amount': '₦4.2M', 'status': 'Paid', 'date': '4/4/18'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/images/financial.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
                    const SizedBox(width: 12),
                    const Text('Financial', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Financial Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF276572),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Contract Value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      const Text('45M', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Earned', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      const Text('Roofing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4AC3C9))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(height: 8, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: 0.65,
                        child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF4AC3C9), borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pending Invoices', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 4),
                          const Text('₦4.2M', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Next Milestone Pay', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 4),
                          const Text('₦6.2M', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Payment Schedule Table
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    color: const Color(0xFFF9FAFB),
                    child: const Row(
                      children: [
                        Expanded(child: Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                        Expanded(child: Center(child: Text('Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467))))),
                        Expanded(child: Text('Date', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                      ],
                    ),
                  ),
                  ...payments.map((p) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(p['amount']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF101828)))),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: p['status'] == 'Paid' ? const Color(0xFFECFDF3) : const Color(0xFFFFFAEB),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(p['status']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: p['status'] == 'Paid' ? const Color(0xFF027A48) : const Color(0xFFB4543E),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Text(p['date']!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, color: Color(0xFF475467)))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276572),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text('Add Milestone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
