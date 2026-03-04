import 'package:flutter/material.dart';

import 'project_card.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _showDropdownFilters = true;
  String _selectedStatus = 'All';

  final List<Map<String, dynamic>> _allProjects = [
    {
      'title': 'Lekki Residential Complex',
      'location': 'Lekki Phase 1, Lagos',
      'status': 'AT RISK',
      'statusColor': const Color(0xFFDC6803), // Orange text
      'budget': '₦45,000,000',
      'days': '78',
      'teamSize': '12',
      'progress': 0.65,
      'hasAlert': false,
    },
    {
      'title': 'Lekki Residential Complex',
      'location': 'Lekki Phase 1, Lagos',
      'status': 'DELAYED',
      'statusColor': const Color(0xFFD92D20), // Red text
      'budget': '₦45,000,000',
      'days': '78',
      'teamSize': '12',
      'progress': 0.65,
      'hasAlert': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedStatus == 'All') {
      return _allProjects;
    }
    return _allProjects.where((p) => p['status'] == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
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
                  child: Image.asset(
                    'assets/images/wrapper.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Filters
            _showDropdownFilters
                ? _buildDropdownFilters()
                : _buildChipFilters(),
            const SizedBox(height: 24),
            // Project List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _filteredProjects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final project = _filteredProjects[index];
                  return ProjectCard(
                    title: project['title'],
                    location: project['location'],
                    status: project['status'],
                    statusColor: project['statusColor'],
                    budget: project['budget'],
                    days: project['days'],
                    teamSize: project['teamSize'],
                    progress: project['progress'],
                    hasAlert: project['hasAlert'],
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
          _buildChip('AT RISK'),
          const SizedBox(width: 12),
          _buildChip('DELAYED'),
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
        width: 105,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF276572) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
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
          Text(
            hint,
            style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF667085),
            size: 18,
          ),
        ],
      ),
    );
  }
}
