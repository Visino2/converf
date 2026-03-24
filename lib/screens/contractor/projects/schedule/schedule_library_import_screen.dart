import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/providers/schedule_providers.dart';
import 'package:converf/features/projects/models/schedule.dart';
import 'package:converf/features/projects/models/schedule_library.dart';

class ScheduleLibraryImportScreen extends ConsumerStatefulWidget {
  final String? scheduleId;
  final String projectId;

  const ScheduleLibraryImportScreen({
    super.key,
    this.scheduleId,
    required this.projectId,
  });

  @override
  ConsumerState<ScheduleLibraryImportScreen> createState() => _ScheduleLibraryImportScreenState();
}

class _ScheduleLibraryImportScreenState extends ConsumerState<ScheduleLibraryImportScreen> {
  final List<ScheduleImportSelection> _selections = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
              const SnackBar(content: Text('Templates imported successfully'), backgroundColor: Colors.green),
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
          if (widget.scheduleId != null && widget.scheduleId != 'library_preview')
          TextButton(
            onPressed: _selections.isEmpty ? null : _importSelections,
            child: Text(
              'Import (${_selections.fold(0, (sum, s) => sum + s.activityIds.length)})',
              style: TextStyle(
                color: _selections.isEmpty ? Colors.grey : const Color(0xFF276572),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: phasesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (phases) {
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
                onSelectionChanged: (selected, activityIds) => _updateSelection(phase.id, selected, activityIds),
                searchQuery: _searchQuery,
              );
            },
          );
        },
      ),
    );
  }

  bool _isPhaseSelected(String phaseId) {
    return _selections.any((s) => s.phaseId == phaseId);
  }

  void _updateSelection(String phaseId, bool selected, List<String> activityIds) {
    setState(() {
      _selections.removeWhere((s) => s.phaseId == phaseId);
      if (selected && activityIds.isNotEmpty) {
        _selections.add(ScheduleImportSelection(phaseId: phaseId, activityIds: activityIds));
      }
    });
  }

  Future<void> _importSelections() async {
    await ref.read(scheduleActionProvider.notifier).importTemplates(
      widget.scheduleId!,
      widget.projectId,
      _selections,
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
    final activitiesAsync = ref.watch(scheduleLibraryActivitiesProvider(widget.phase.id));

    return Column(
      children: [
        CheckboxListTile(
          title: Text(widget.phase.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
          ),
        ),
        if (_isExpanded)
          activitiesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => const Text('Error loading activities'),
            data: (activities) {
              final filteredActivities = activities.where((activity) {
                return activity.description.toLowerCase().contains(widget.searchQuery) ||
                       (activity.activityCode?.toLowerCase().contains(widget.searchQuery) ?? false) ||
                       widget.searchQuery.isEmpty;
              }).toList();

              if (filteredActivities.isEmpty && widget.searchQuery.isNotEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No matching activities', style: TextStyle(fontSize: 12, color: Colors.grey)),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Column(
                  children: filteredActivities.map((activity) => CheckboxListTile(
                    title: Text(activity.description, style: const TextStyle(fontSize: 14)),
                    subtitle: Text('Duration: ${activity.standardDurationDays} days'),
                    value: _selectedActivityIds.contains(activity.id),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedActivityIds.add(activity.id);
                        } else {
                          _selectedActivityIds.remove(activity.id);
                        }
                      });
                      widget.onSelectionChanged(_selectedActivityIds.isNotEmpty, _selectedActivityIds);
                    },
                  )).toList(),
                ),
              );
            },
          ),
        const Divider(),
      ],
    );
  }
}
