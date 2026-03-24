import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../daily_reports/daily_reports_screen.dart';
import '../../../product_owner/widgets/dashboard/field_inspections_modal.dart';
import '../schedule/schedule_screen.dart';
import '../../../product_owner/widgets/dashboard/overview_modal.dart';
import 'project_documents_tab.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_images_modal.dart';
import '../../../product_owner/widgets/dashboard/projects/project_team_modal.dart';


class ProjectHubModal extends ConsumerStatefulWidget {
  final String projectId;
  final int initialTabIndex;

  const ProjectHubModal({
    super.key,
    required this.projectId,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<ProjectHubModal> createState() => _ProjectHubModalState();
}

class _ProjectHubModalState extends ConsumerState<ProjectHubModal> {
  late int _selectedTabIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Overview',          'icon': 'assets/images/home-2.svg'},
    {'label': 'Schedule',          'icon': 'assets/images/calendar-3.svg'},
    {'label': 'Field Inspections', 'icon': 'assets/images/field_inspection.svg'},
    {'label': 'Daily Reports',     'icon': 'assets/images/document-1.svg'},
    {'label': 'Documents',         'icon': 'assets/images/document.svg'},
    {'label': 'Images',            'icon': 'assets/images/camera.svg'},
    {'label': 'Team',              'icon': 'assets/images/team.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle and Header
              _buildHeader(context),
              
              // Horizontal Tab Bar
              _buildTabBar(),

              const Divider(height: 1, color: Color(0xFFEAECF0)),

              // Content Area
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D5DD),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tabs[_selectedTabIndex]['label'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF276572) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF276572) : const Color(0xFFD0D5DD),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    tab['icon'],
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      isSelected ? Colors.white : const Color(0xFF344054),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tab['label'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF344054),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0: // Overview
        return OverviewModal(projectId: widget.projectId);
      case 1: // Schedule
        return ScheduleScreen(projectId: widget.projectId, isEmbedded: true);
      case 2: // Field Inspections
        return FieldInspectionsModal(projectId: widget.projectId, isEmbedded: true);
      case 3: // Daily Reports
        return DailyReportsScreen(projectId: widget.projectId, isEmbedded: true);
      case 4: // Documents
        return ProjectDocumentsTab(projectId: widget.projectId, isEmbedded: true);
      case 5: // Images
        return ProjectImagesModal(projectId: widget.projectId, isEmbedded: true);
      case 6: // Team
        return ProjectTeamModal(projectId: widget.projectId);
      default:
        return const SizedBox();
    }
  }
}
