import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../features/daily_reports/models/daily_report_models.dart';
import '../../../../features/daily_reports/providers/daily_report_providers.dart';

class DailyReportFormScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? reportId; // If null, creating new
  final String? initialDate;

  const DailyReportFormScreen({
    super.key,
    required this.projectId,
    this.reportId,
    this.initialDate,
  });

  @override
  ConsumerState<DailyReportFormScreen> createState() => _DailyReportFormScreenState();
}

class _DailyReportFormScreenState extends ConsumerState<DailyReportFormScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Form State
  String? _selectedDate;
  final Map<String, dynamic> _weatherData = {};
  final Map<String, dynamic> _resourcesData = {};
  List<Map<String, dynamic>> _activityUpdates = [];
  List<Map<String, dynamic>> _issues = [];
  List<Map<String, dynamic>> _tomorrowPlan = [];
  bool _siteAccessible = true;
  bool _weatherStoppage = false;
  String _weatherHoursLost = '0';

  /// Returns _weatherHoursLost clamped to a max of 12, as required by the API.
  String get _clampedWeatherHoursLost {
    final parsed = double.tryParse(_weatherHoursLost) ?? 0;
    return parsed.clamp(0, 12).toString();
  }
  String _concretePourPossible = 'na';
  String _laborSufficiency = 'yes';
  bool _equipmentDown = false;
  bool _materialShortage = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now().toIso8601String().split('T')[0];
    
    if (widget.reportId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadReportData());
    }
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final report = await ref.read(dailyReportDetailProvider((projectId: widget.projectId, reportId: widget.reportId!)).future);
      
      setState(() {
        _selectedDate = report.reportDate;
        _siteAccessible = report.siteAccessible ?? true;
        _weatherStoppage = report.weatherStoppage ?? false;
        
        if (report.temperatureC != null) _weatherData['temperature_c'] = report.temperatureC;
        if (report.weatherCondition != null) _weatherData['weather_condition'] = report.weatherCondition;
        _weatherHoursLost = report.weatherHoursLost ?? '0';
        _concretePourPossible = report.concretePourPossible ?? 'na';
        _laborSufficiency = report.laborSufficiency ?? 'yes';
        _equipmentDown = report.equipmentDown ?? false;
        _materialShortage = report.materialShortage ?? false;

        if (report.laborCount != null) _resourcesData['labor_count'] = report.laborCount;
        if (report.equipmentOperatingCount != null) _resourcesData['equipment_operating_count'] = report.equipmentOperatingCount;
        if (report.deliveriesCount != null) _resourcesData['deliveries_count'] = report.deliveriesCount;
        
        _activityUpdates = report.activityUpdates.map((a) => {
          'project_activity_id': a.projectActivityId,
          'actual_pct': int.tryParse(a.actualPct) ?? 0,
          'status': a.status,
          'title': 'Activity Update',
        }).toList();

        _issues = report.issues.map((i) => {
          'issue_type': i.issueType,
          'impact_days': int.tryParse(i.impactDays) ?? 0,
          'resolution_type': i.resolutionType ?? 'pending',
          'resolution_note': i.resolutionNote,
          'assigned_to': i.assignedTo,
        }).toList();

        _tomorrowPlan = report.tomorrowPlan.map((a) => {
          'project_activity_id': a.projectActivityId,
          'activity_label': 'Planned Activity',
          'status': a.status,
          'start_time': '07:00',
          'crew_size': 5,
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading report: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: const Center(child: CircularProgressIndicator(color: Color(0xFF276572))));

    final metaAsync = ref.watch(dailyReportFormMetaProvider((projectId: widget.projectId, date: _selectedDate!)));

    return metaAsync.when(
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: const Text('New Report', style: TextStyle(color: Colors.black))),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF276572)))
      ),
      error: (err, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text('New Report', style: TextStyle(color: Colors.black)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  err.toString().contains('selected date is invalid') 
                    ? 'The selected date is invalid for this project.'
                    : 'Error loading defaults: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _changeDate(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF276572)),
                  child: const Text('Change Date', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (meta) {
        // Initialize updates from meta if completely empty (new report)
        if (_activityUpdates.isEmpty && meta.todayCriticalActivities.isNotEmpty && widget.reportId == null) {
          _activityUpdates = meta.todayCriticalActivities.map((a) => {
            'project_activity_id': a['project_activity_id'],
            'title': a['title'],
            'actual_pct': 0,
            'status': 'not_started',
          }).toList();
        }

        if (_tomorrowPlan.isEmpty && meta.tomorrowCriticalActivities.isNotEmpty && widget.reportId == null) {
          _tomorrowPlan = meta.tomorrowCriticalActivities.map((a) => {
            'project_activity_id': a['project_activity_id'],
            'activity_label': a['title'],
            'status': 'planned',
            'start_time': a['suggested_start_time'] ?? '07:00',
            'crew_size': a['suggested_crew_size'] ?? 5,
          }).toList();
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.reportId == null ? 'New Daily Report' : 'Edit Daily Report',
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _saveDraft,
                child: const Text('Save Draft', style: TextStyle(color: Color(0xFF276572), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          body: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 4) {
                setState(() => _currentStep++);
              } else {
                _submitReport();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Back', style: TextStyle(color: Color(0xFF344054))),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF276572),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text(
                          _currentStep == 4 ? 'Submit Report' : 'Next',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('1'),
                isActive: _currentStep >= 0,
                content: _buildDateStep(),
              ),
              Step(
                title: const Text('2'),
                isActive: _currentStep >= 1,
                content: _buildSiteStep(meta),
              ),
              Step(
                title: const Text('3'),
                isActive: _currentStep >= 2,
                content: _buildWorkStep(meta),
              ),
              Step(
                title: const Text('4'),
                isActive: _currentStep >= 3,
                content: _buildIssuesStep(meta),
              ),
              Step(
                title: const Text('5'),
                isActive: _currentStep >= 4,
                content: _buildTomorrowStep(meta),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changeDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_selectedDate!) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked.toIso8601String().split('T')[0]);
    }
  }

  Widget _buildDateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Report Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _changeDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEAECF0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedDate ?? 'Select Date', style: const TextStyle(fontSize: 16)),
                SvgPicture.asset(
                  'assets/images/Calendar.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(Color(0xFF667085), BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSiteStep(DailyReportFormMeta meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Weather Conditions'),
        _buildDropdownField('Condition', _weatherData['weather_condition'] ?? meta.defaults['weather_condition'], 
          (meta.options['weather_conditions'] as List?)?.map((e) => e.toString()).toList() ?? 
          ['clear', 'light_rain', 'heavy_rain', 'storm', 'extreme_heat'], (val) {
          setState(() => _weatherData['weather_condition'] = val);
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField('Temperature (°C)', initialValue: _weatherData['temperature_c']?.toString() ?? meta.defaults['temperature_c']?.toString(), onChanged: (val) {
                setState(() => _weatherData['temperature_c'] = val);
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHoursLostField(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdownField('Concrete Pour Possible?', _concretePourPossible, 
          (meta.options['yes_no_na'] as List?)?.map((e) => e.toString()).toList() ?? 
          ['yes', 'no', 'na'], (val) {
          setState(() => _concretePourPossible = val ?? 'na');
        }),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Site Accessible?', style: TextStyle(fontWeight: FontWeight.w600)),
          value: _siteAccessible,
          activeThumbColor: const Color(0xFF276572),
          onChanged: (val) => setState(() => _siteAccessible = val),
        ),
        SwitchListTile(
          title: const Text('Weather Stoppage?', style: TextStyle(fontWeight: FontWeight.w600)),
          value: _weatherStoppage,
          activeThumbColor: const Color(0xFF276572),
          onChanged: (val) => setState(() => _weatherStoppage = val),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Resources & Logistics'),
        _buildDropdownField('Labor Sufficiency', _laborSufficiency, 
          (meta.options['labor_sufficiency'] as List?)?.map((e) => e.toString()).toList() ?? 
          ['yes', 'no', 'overstaffed'], (val) {
          setState(() => _laborSufficiency = val ?? 'yes');
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField('Labor Count', initialValue: _resourcesData['labor_count']?.toString(), onChanged: (val) {
                setState(() => _resourcesData['labor_count'] = int.tryParse(val));
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField('Equipment Running', initialValue: _resourcesData['equipment_operating_count']?.toString(), onChanged: (val) {
                setState(() => _resourcesData['equipment_operating_count'] = int.tryParse(val));
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Deliveries Count', initialValue: _resourcesData['deliveries_count']?.toString(), onChanged: (val) {
          setState(() => _resourcesData['deliveries_count'] = int.tryParse(val));
        }),
        SwitchListTile(
          title: const Text('Equipment Down?', style: TextStyle(fontWeight: FontWeight.w600)),
          value: _equipmentDown,
          activeThumbColor: Colors.red,
          onChanged: (val) => setState(() => _equipmentDown = val),
        ),
        SwitchListTile(
          title: const Text('Material Shortage?', style: TextStyle(fontWeight: FontWeight.w600)),
          value: _materialShortage,
          activeThumbColor: Colors.red,
          onChanged: (val) => setState(() => _materialShortage = val),
        ),
      ],
    );
  }

  Widget _buildWorkStep(DailyReportFormMeta meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Activity Updates'),
        if (_activityUpdates.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No activities scheduled for today.', style: TextStyle(color: Colors.grey))),
          ),
        ..._activityUpdates.map((update) => _buildActivityItem(update, meta)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> update, DailyReportFormMeta meta) {
    final activityId = update['project_activity_id'];
    final metaActivity = meta.todayCriticalActivities.firstWhere(
      (a) => a['project_activity_id'] == activityId,
      orElse: () => null,
    );
    final title = metaActivity?['title'] ?? update['title'] ?? 'Activity Update';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAECF0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: (update['actual_pct'] as num).toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${update['actual_pct']}%',
                  activeColor: const Color(0xFF276572),
                  onChanged: (val) {
                    setState(() => update['actual_pct'] = val.round());
                  },
                ),
              ),
              Text('${update['actual_pct']}%', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesStep(DailyReportFormMeta meta) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Issues & Delays'),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _issues.add({
                    'issue_type': (meta.options['issue_types'] as List?)?.first ?? 'other',
                    'impact_days': 0,
                    'resolution_type': '',
                    'resolution_note': '',
                  });
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Issue'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF276572)),
            ),
          ],
        ),
        if (_issues.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Text('No issues reported today.', style: TextStyle(color: Colors.grey)),
          ),
        ..._issues.asMap().entries.map((entry) {
          final index = entry.key;
          final issue = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFFEAECF0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildDropdownField('Issue Type', issue['issue_type'], 
                        (meta.options['issue_types'] as List?)?.map((e) => e.toString()).toList() ?? 
                        ['weather_delay', 'material_shortage', 'labor_shortage', 'equipment_breakdown', 'other'], 
                        (val) => setState(() => issue['issue_type'] = val),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() => _issues.removeAt(index)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Impact (Days)', initialValue: issue['impact_days'].toString(), onChanged: (val) {
                        setState(() => issue['impact_days'] = int.tryParse(val) ?? 0);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdownField('Resolution Type', issue['resolution_type'] ?? '', 
                  ['', ...(meta.options['resolution_types'] as List?)?.map((e) => e.toString()).toList() ?? 
                  ['waiting_on_client', 'ordered_replacement', 'adding_extra_crew', 'working_overtime', 'other']], 
                  (val) => setState(() => issue['resolution_type'] = val),
                ),
                const SizedBox(height: 12),
                if (meta.issueAssignees.isNotEmpty) ...[
                  (() {
                    final assignedAttendee = meta.issueAssignees.firstWhere(
                      (a) => a['id']?.toString() == issue['assigned_to']?.toString(), 
                      orElse: () => null
                    );
                    final assignedName = assignedAttendee != null 
                        ? '${assignedAttendee['first_name']} ${assignedAttendee['last_name']}' 
                        : '';
                    
                    final options = ['', ...meta.issueAssignees.map((a) => '${a['first_name']} ${a['last_name']}').toSet()];

                    return _buildDropdownField('Assigned To', assignedName, options, (val) {
                      if (val == null || val.isEmpty) {
                        setState(() => issue['assigned_to'] = null);
                      } else {
                        final attendee = meta.issueAssignees.firstWhere(
                          (a) => '${a['first_name']} ${a['last_name']}' == val,
                          orElse: () => null,
                        );
                        setState(() => issue['assigned_to'] = attendee?['id']);
                      }
                    });
                  })(),
                  const SizedBox(height: 12),
                ],
                _buildTextField('Notes/Resolution', initialValue: issue['resolution_note'], onChanged: (val) {
                  setState(() => issue['resolution_note'] = val);
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTomorrowStep(DailyReportFormMeta meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tomorrow\'s Plan'),
        if (_tomorrowPlan.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No activities scheduled for tomorrow.', style: TextStyle(color: Colors.grey))),
          ),
        ..._tomorrowPlan.map((update) => _buildTomorrowItem(update, meta)),
      ],
    );
  }

  Widget _buildTomorrowItem(Map<String, dynamic> update, DailyReportFormMeta meta) {
    final activityId = update['project_activity_id'];
    final metaActivity = meta.tomorrowCriticalActivities.firstWhere(
      (a) => a['project_activity_id'] == activityId,
      orElse: () => null,
    );
    final title = metaActivity?['title'] ?? update['title'] ?? 'Planned Activity';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAECF0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF276572)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.check_circle, color: Color(0xFF276572), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Start Time', initialValue: update['start_time'] ?? '07:00', onChanged: (val) {
                  setState(() => update['start_time'] = val);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Crew Size', initialValue: update['crew_size']?.toString() ?? '5', onChanged: (val) {
                  setState(() => update['crew_size'] = int.tryParse(val) ?? 5);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _toOptionLabel(String value) {
    if (value.isEmpty) return '';
    return value.replaceFirst('__none', '').replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      if (word.toLowerCase() == 'rfi') return 'RFI';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildTextField(String label, {String? initialValue, Function(String)? onChanged}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildHoursLostField() {
    final parsed = double.tryParse(_weatherHoursLost) ?? 0;
    final isOver = parsed > 12;
    return TextFormField(
      initialValue: _weatherHoursLost,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Hours Lost (max 12)',
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        errorText: isOver ? 'Max 12 hours' : null,
        errorStyle: const TextStyle(color: Colors.orange),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      onChanged: (val) => setState(() => _weatherHoursLost = val),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    String? effectiveValue = options.any((o) => o == value) ? value : (options.contains('') ? '' : (options.isNotEmpty ? options.first : null));

    return DropdownButtonFormField<String>(
      initialValue: effectiveValue,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: options.map((o) => DropdownMenuItem(
        value: o, 
        child: Text(o.isEmpty ? 'None' : _toOptionLabel(o))
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _saveDraft() async {
    setState(() => _isLoading = true);
    try {
      final payload = DailyReportDraftPayload(
        reportDate: _selectedDate!,
        weather: {
          ..._weatherData,
          'weather_hours_lost': _clampedWeatherHoursLost,
          'concrete_pour_possible': _concretePourPossible,
        },
        resources: {
          ..._resourcesData,
          'labor_sufficiency': _laborSufficiency,
          'equipment_down': _equipmentDown,
          'material_shortage': _materialShortage,
        },
        activityUpdates: _activityUpdates,
        issues: _issues,
        tomorrowPlan: _tomorrowPlan,
        siteAccessible: _siteAccessible,
        weatherStoppage: _weatherStoppage,
      );
      
      await ref.read(dailyReportActionProvider.notifier).upsertDraft(widget.projectId, payload);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().contains('Exception:') ? e.toString().split('Exception:')[1] : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving draft: $errorMsg')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReport() async {
    setState(() => _isLoading = true);
    try {
      String? reportId = widget.reportId;
      
      // Upsert draft first to ensure the latest data is on the server
      final payload = DailyReportDraftPayload(
        reportDate: _selectedDate!,
        weather: {
          ..._weatherData,
          'weather_hours_lost': _clampedWeatherHoursLost,
          'concrete_pour_possible': _concretePourPossible,
        },
        resources: {
          ..._resourcesData,
          'labor_sufficiency': _laborSufficiency,
          'equipment_down': _equipmentDown,
          'material_shortage': _materialShortage,
        },
        activityUpdates: _activityUpdates,
        issues: _issues,
        tomorrowPlan: _tomorrowPlan,
        siteAccessible: _siteAccessible,
        weatherStoppage: _weatherStoppage,
      );
      
      final response = await ref.read(dailyReportActionProvider.notifier).upsertDraft(widget.projectId, payload);
      reportId ??= response['data']?['id']?.toString();

      if (reportId != null) {
        await ref.read(dailyReportActionProvider.notifier).submitReport(widget.projectId, reportId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().contains('Exception:') ? e.toString().split('Exception:')[1] : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $errorMsg')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
