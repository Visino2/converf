import 'dart:async';
import 'package:flutter/material.dart';

import 'contractor_project_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/projects/providers/project_providers.dart';
import '../../../../features/projects/models/project.dart';

class ContractorProjectsScreen extends ConsumerStatefulWidget {
  const ContractorProjectsScreen({super.key});

  @override
  ConsumerState<ContractorProjectsScreen> createState() =>
      _ContractorProjectsScreenState();
}

class _ContractorProjectsScreenState
    extends ConsumerState<ContractorProjectsScreen> {
  bool _showDropdownFilters = true;
  String _selectedStatus = 'All Status';
  String _selectedType = 'All Types';
  String _selectedMethod = 'All Method';
  Timer? _refreshTimer;

  final List<String> _statusOptions = [
    'All Status',
    'On Track',
    'At Risk',
    'Delay',
    'Completed',
  ];
  final List<String> _typeOptions = [
    'All Types',
    'Residential',
    'Commercial',
    'Roadway',
    'Infrastructure',
  ];
  final List<String> _methodOptions = ['All Method', 'Open Tender', 'Direct'];

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint('[ContractorProjects] Auto-refreshing projects...');
        ref.invalidate(assignedProjectsProvider(1));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  List<Project> _filterProjects(List<Project> projects) {
    return projects.where((p) {
      // Status Filter
      bool matchesStatus = true;
      if (_selectedStatus != 'All Status' && _selectedStatus != 'All') {
        ProjectStatus? filterStatus;
        switch (_selectedStatus) {
          case 'At Risk':
            filterStatus = ProjectStatus.atRisk;
            break;
          case 'Delay':
            filterStatus = ProjectStatus.delayed;
            break;
          case 'On Track':
            filterStatus = ProjectStatus.onTrack;
            break;
          case 'Completed':
            filterStatus = ProjectStatus.completed;
            break;
        }
        matchesStatus = p.status == filterStatus;
      }

      // Type Filter
      bool matchesType = true;
      if (_selectedType != 'All Types') {
        matchesType =
            p.constructionType.toLowerCase() == _selectedType.toLowerCase();
      }

      // Method Filter
      bool matchesMethod = true;
      if (_selectedMethod != 'All Method' && _selectedMethod != 'All') {
        matchesMethod = p.assignmentMethod.toLowerCase().contains(
          _selectedMethod.split(' ').first.toLowerCase(),
        );
      }

      return matchesStatus && matchesType && matchesMethod;
    }).toList();
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
                  child: SvgPicture.asset(
                    'assets/images/wrapper.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _showDropdownFilters
                ? _buildDropdownFilters()
                : _buildChipFilters(),
            const SizedBox(height: 24),
            Expanded(
              child: projectsAsync.when(
                loading: () => projectsAsync.hasValue
                    ? _buildProjectsList(projectsAsync.value!.data)
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF276572),
                        ),
                      ),
                error: (error, _) => Center(
                  child: Text(
                    'Error loading projects: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                data: (response) => _buildProjectsList(response.data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(List<Project> allProjects) {
    final projects = _filterProjects(allProjects);

    if (projects.isEmpty) {
      return const Center(
        child: Text(
          'No assigned projects match your filters.',
          style: TextStyle(color: Color(0xFF667085)),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      cacheExtent: 500,
      itemCount: projects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final project = projects[index];
        final hasAlert =
            project.status == ProjectStatus.delayed ||
            project.status == ProjectStatus.atRisk;

        return RepaintBoundary(
          child: ContractorProjectCard(project: project, hasAlert: hasAlert),
        );
      },
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
    bool isSelected =
        _selectedStatus == label ||
        (label == 'All' && _selectedStatus == 'All Status');
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = label == 'All' ? 'All Status' : label;
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
        Expanded(
          child: _buildDropdown(
            _selectedStatus,
            _statusOptions,
            (val) => setState(() => _selectedStatus = val),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            _selectedType,
            _typeOptions,
            (val) => setState(() => _selectedType = val),
          ),
        ),
        const SizedBox(width: 12),
        _buildDropdown(
          _selectedMethod,
          _methodOptions,
          (val) => setState(() => _selectedMethod = val),
          isShort: true,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String current,
    List<String> options,
    ValueChanged<String> onChanged, {
    bool isShort = false,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 44),
      itemBuilder: (context) => options
          .map(
            (opt) => PopupMenuItem(
              value: opt,
              child: Row(
                children: [
                  if (opt == current)
                    const Icon(Icons.check, color: Color(0xFF276572), size: 18)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(opt, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isShort ? 20 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isShort ? const Color(0xFF276572) : Colors.white,
          border: isShort ? null : Border.all(color: const Color(0xFFD0D5DD)),
          borderRadius: BorderRadius.circular(isShort ? 24 : 8),
        ),
        child: Row(
          mainAxisSize: isShort ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isShort ? 'All' : current,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isShort ? FontWeight.w600 : FontWeight.normal,
                color: isShort ? Colors.white : const Color(0xFF667085),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (!isShort) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF667085),
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
