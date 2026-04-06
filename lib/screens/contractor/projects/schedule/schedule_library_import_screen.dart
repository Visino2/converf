import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/providers/schedule_providers.dart';
import 'package:converf/features/projects/models/schedule.dart';
import 'package:converf/features/projects/models/schedule_library.dart';

class ScheduleLibraryImportScreen extends ConsumerStatefulWidget {
  final String? scheduleId;
  final String? projectId;
  final String? bidId;

  const ScheduleLibraryImportScreen({
    super.key,
    this.scheduleId,
    this.projectId,
    this.bidId,
  });

  @override
  ConsumerState<ScheduleLibraryImportScreen> createState() =>
      _ScheduleLibraryImportScreenState();
}

class _ScheduleLibraryImportScreenState
    extends ConsumerState<ScheduleLibraryImportScreen> {
  final List<ScheduleImportSelection> _selections = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Widget _buildLibrarySkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 180,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(scheduleLibraryPhasesProvider);

    ref.listen(scheduleActionProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Templates imported successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search library...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          if (widget.scheduleId != null &&
              widget.scheduleId != 'library_preview')
            TextButton(
              onPressed: _selections.isEmpty ? null : _importSelections,
              child: Text(
                'Import (${_selections.fold(0, (sum, s) => sum + s.activityIds.length)})',
                style: TextStyle(
                  color: _selections.isEmpty
                      ? Colors.grey
                      : const Color(0xFF276572),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: phasesAsync.when(
        loading: () => phasesAsync.hasValue
            ? _buildLibraryContent(phasesAsync.value!)
            : _buildLibrarySkeleton(),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (phases) => _buildLibraryContent(phases),
      ),
    );
  }

  Widget _buildLibraryContent(List<TemplatePhase> phases) {
    final filteredPhases = phases.where((phase) {
      final matchesPhase = phase.name.toLowerCase().contains(_searchQuery);
      return matchesPhase || _searchQuery.isEmpty;
    }).toList();

    if (filteredPhases.isEmpty) {
      return const Center(child: Text('No matching phases found'));
    }

    return ListView.builder(
      itemCount: filteredPhases.length,
      itemBuilder: (context, index) {
        final phase = filteredPhases[index];
        return _LibraryPhaseTile(
          phase: phase,
          isSelected: _isPhaseSelected(phase.id),
          onSelectionChanged: (selected, activityIds) =>
              _updateSelection(phase.id, selected, activityIds),
          searchQuery: _searchQuery,
        );
      },
    );
  }

  bool _isPhaseSelected(String phaseId) {
    return _selections.any((s) => s.phaseId == phaseId);
  }

  void _updateSelection(
    String phaseId,
    bool selected,
    List<String> activityIds,
  ) {
    setState(() {
      _selections.removeWhere((s) => s.phaseId == phaseId);
      if (selected && activityIds.isNotEmpty) {
        _selections.add(
          ScheduleImportSelection(phaseId: phaseId, activityIds: activityIds),
        );
      }
    });
  }

  Future<void> _importSelections() async {
    await ref.read(scheduleActionProvider.notifier).importTemplates(
          widget.scheduleId!,
          projectId: widget.projectId,
          bidId: widget.bidId,
          selections: _selections,
        );
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _LibraryPhaseTile extends ConsumerStatefulWidget {
  final TemplatePhase phase;
  final bool isSelected;
  final String searchQuery;
  final Function(bool, List<String>) onSelectionChanged;

  const _LibraryPhaseTile({
    required this.phase,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.searchQuery,
  });

  @override
  ConsumerState<_LibraryPhaseTile> createState() => _LibraryPhaseTileState();
}

class _LibraryPhaseTileState extends ConsumerState<_LibraryPhaseTile> {
  bool _isExpanded = false;
  final List<String> _selectedActivityIds = [];

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(
      scheduleLibraryActivitiesProvider(widget.phase.id),
    );

    return Column(
      children: [
        CheckboxListTile(
          title: Text(
            widget.phase.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${widget.phase.totalActivities} Activities'),
          value: widget.isSelected,
          onChanged: (val) {
            if (val == true) {
              // Select all activities by default when phase is checked
              activitiesAsync.whenData((activities) {
                setState(() {
                  _selectedActivityIds.clear();
                  _selectedActivityIds.addAll(activities.map((a) => a.id));
                  _isExpanded = true;
                });
                widget.onSelectionChanged(true, _selectedActivityIds);
              });
            } else {
              setState(() {
                _selectedActivityIds.clear();
              });
              widget.onSelectionChanged(false, []);
            }
          },
          secondary: IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF667085),
            ),
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
          ),
        ),
        if (_isExpanded)
          _PhaseActivitiesList(
            phaseId: widget.phase.id,
            searchQuery: widget.searchQuery,
            selectedIds: _selectedActivityIds,
            onChanged: (activityId, selected) {
              setState(() {
                if (selected) {
                  _selectedActivityIds.add(activityId);
                } else {
                  _selectedActivityIds.remove(activityId);
                }
              });
              widget.onSelectionChanged(
                _selectedActivityIds.isNotEmpty,
                _selectedActivityIds,
              );
            },
          ),
        const Divider(height: 1, color: Color(0xFFEAECF0)),
      ],
    );
  }
}

class _PhaseActivitiesList extends ConsumerWidget {
  final String phaseId;
  final String searchQuery;
  final List<String> selectedIds;
  final Function(String, bool) onChanged;

  const _PhaseActivitiesList({
    required this.phaseId,
    required this.searchQuery,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(
      scheduleLibraryActivitiesProvider(phaseId),
    );

    return activitiesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF276572),
            ),
          ),
        ),
      ),
      error: (err, stack) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Error loading activities',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
      data: (activities) {
        final filteredActivities = activities.where((activity) {
          return activity.description.toLowerCase().contains(searchQuery) ||
              activity.activityCode.toLowerCase().contains(searchQuery) ||
              searchQuery.isEmpty;
        }).toList();

        if (filteredActivities.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              searchQuery.isEmpty
                  ? 'No activities found'
                  : 'No matching activities',
              style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: filteredActivities
                .map(
                  (activity) => CheckboxListTile(
                    dense: true,
                    activeColor: const Color(0xFF276572),
                    title: Text(
                      activity.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF344054),
                      ),
                    ),
                    subtitle: Text(
                      '${activity.activityCode} • ${activity.standardDurationDays} days',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                    value: selectedIds.contains(activity.id),
                    onChanged: (val) => onChanged(activity.id, val ?? false),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
