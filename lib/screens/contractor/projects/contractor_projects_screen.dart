import 'package:flutter/material.dart';

import 'contractor_project_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContractorProjectsScreen extends StatefulWidget {
  const ContractorProjectsScreen({super.key});

  @override
  State<ContractorProjectsScreen> createState() => _ContractorProjectsScreenState();
}

class _ContractorProjectsScreenState extends State<ContractorProjectsScreen> {
  bool _showDropdownFilters = true;
  String _selectedStatus = 'All';

  final List<Map<String, dynamic>> _allProjects = [
    {
      'title': 'Lekki Residential Complex',
      'location': 'Lekki Phase 1, Lagos',
      'status': 'AT RISK',
      'statusColor': const Color(0xFFDC6803),
      'budget': '₦30,600,000 /45M',
      'phase': 'Phase 8 of 12',
      'progress': 0.65,
      'hasAlert': false,
    },
    {
      'title': 'Lekki Residential Complex',
      'location': 'Lekki Phase 1, Lagos',
      'status': 'AT RISK',
      'statusColor': const Color(0xFFDC6803),
      'budget': '₦30,600,000 /45M',
      'phase': 'Phase 8 of 12',
      'progress': 0.65,
      'hasAlert': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedStatus == 'All') {
      return _allProjects;
    }
    final statusMap = {
      'On Track': 'ON TRACK',
      'At Risk': 'AT RISK',
      'Delay': 'DELAYED',
    };
    final mappedStatus = statusMap[_selectedStatus] ?? _selectedStatus;
    return _allProjects.where((p) => p['status'] == mappedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _filteredProjects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final project = _filteredProjects[index];
                  return ContractorProjectCard(
                    title: project['title'],
                    location: project['location'],
                    status: project['status'],
                    statusColor: project['statusColor'],
                    budget: project['budget'],
                    phase: project['phase'],
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
