import 'package:flutter/material.dart';

import 'contractor_project_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/projects/providers/project_providers.dart';
import '../../../../features/projects/models/project.dart';

class ContractorProjectsScreen extends ConsumerStatefulWidget {
  const ContractorProjectsScreen({super.key});

  @override
  ConsumerState<ContractorProjectsScreen> createState() => _ContractorProjectsScreenState();
}

class _ContractorProjectsScreenState extends ConsumerState<ContractorProjectsScreen> {
  bool _showDropdownFilters = true;
  String _selectedStatus = 'All';

  List<Project> _filterProjects(List<Project> projects) {
    if (_selectedStatus == 'All' || _selectedStatus == 'All Status') {
      return projects;
    }
    
    ProjectStatus? filterStatus;
    switch (_selectedStatus) {
      case 'At Risk': filterStatus = ProjectStatus.atRisk; break;
      case 'Delay': filterStatus = ProjectStatus.delayed; break;
      case 'On Track': filterStatus = ProjectStatus.onTrack; break;
      case 'Completed': filterStatus = ProjectStatus.completed; break;
    }
    
    if (filterStatus == null) return projects;
    return projects.where((p) => p.status == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(assignedProjectsProvider(1));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDropdownFilters = !_showDropdownFilters;
                    });
                  },
                  child: SvgPicture.asset('assets/images/wrapper.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _showDropdownFilters ? _buildDropdownFilters() : _buildChipFilters(),
            const SizedBox(height: 24),
            Expanded(
              child: projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
                error: (error, _) => Center(
                  child: Text('Error loading projects: $error', style: const TextStyle(color: Colors.red)),
                ),
                data: (response) {
                  final projects = _filterProjects(response.data);
                  
                  if (projects.isEmpty) {
                    return const Center(
                      child: Text('No assigned projects.', style: TextStyle(color: Color(0xFF667085))),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    cacheExtent: 500,
                    itemCount: projects.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final hasAlert = project.status == ProjectStatus.delayed || project.status == ProjectStatus.atRisk;
                      
                      return RepaintBoundary(
                        child: ContractorProjectCard(
                          project: project,
                          hasAlert: hasAlert,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('All'),
          const SizedBox(width: 12),
          _buildChip('On Track'),
          const SizedBox(width: 12),
          _buildChip('At Risk'),
          const SizedBox(width: 12),
          _buildChip('Delay'),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    bool isSelected = _selectedStatus == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF276572) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475467),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilters() {
    return Row(
      children: [
        Expanded(child: _buildDropdown('All Status')),
        const SizedBox(width: 12),
        Expanded(child: _buildDropdown('All Types')),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF276572),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'All',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5DD)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: const TextStyle(fontSize: 14, color: Color(0xFF667085))),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085), size: 18),
        ],
      ),
    );
  }
}
