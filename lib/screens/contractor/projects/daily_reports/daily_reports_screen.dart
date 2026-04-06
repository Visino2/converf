import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../features/daily_reports/models/daily_report_models.dart';
import '../../../../features/daily_reports/providers/daily_report_providers.dart';
import '../../../../features/projects/models/project.dart';
import '../../../../features/projects/providers/project_providers.dart';
import '../../../../features/projects/providers/schedule_providers.dart';
import 'package:intl/intl.dart';
import 'daily_report_form_screen.dart';

class DailyReportsScreen extends ConsumerStatefulWidget {
  final String projectId;
  final bool isEmbedded;

  const DailyReportsScreen({
    super.key,
    required this.projectId,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<DailyReportsScreen> createState() => _DailyReportsScreenState();
}

class _DailyReportsScreenState extends ConsumerState<DailyReportsScreen> {
  DailyReportStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    // Prefetch today's form metadata so the "Create Report" screen opens instantly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now().toIso8601String().split('T')[0];
      ref
          .read(
            dailyReportFormMetaProvider((
              projectId: widget.projectId,
              date: today,
            )).future,
          )
          .ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(
      dailyReportsProvider((
        projectId: widget.projectId,
        status: _filterStatus?.name,
      )),
    );
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));

    final content = reportsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF276572)),
      ),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $err'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(dailyReportsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (response) {
        final reports = response.data;

        return projectAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF276572)),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading project: $err'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(projectDetailsProvider(widget.projectId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (projResponse) {
            final project = projResponse.data;
            final visibleReports = _resolveMissingReports(project, reports);

            if (visibleReports.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dailyReportsProvider);
                ref.invalidate(projectDetailsProvider(widget.projectId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                shrinkWrap: widget.isEmbedded,
                physics: widget.isEmbedded
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                itemCount: visibleReports.length,
                itemBuilder: (context, index) {
                  final item = visibleReports[index];
                  if (item is DailyReport) {
                    return _buildReportCard(item);
                  } else if (item is Map<String, dynamic>) {
                    return _buildMissingReportCard(item);
                  }
                  return const SizedBox();
                },
              ),
            );
          },
        );
      },
    );

    if (widget.isEmbedded) {
      return SingleChildScrollView(child: content);
    }

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
          'Daily Reports',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/filter.svg',
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReport,
        backgroundColor: const Color(0xFF276572),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<dynamic> _resolveMissingReports(
    Project? project,
    List<DailyReport> reports,
  ) {
    if (project == null || project.startDate.isEmpty || _filterStatus != null) {
      return reports;
    }

    try {
      final startDate = DateTime.parse(project.startDate);
      final today = DateTime.now();
      final lastDate = project.status == ProjectStatus.completed
          ? DateTime.parse(project.endDate)
          : today;

      // Build a Map for O(1) lookup by date string instead of O(N) firstWhere
      final Map<String, DailyReport> reportByDate = {
        for (final r in reports) r.reportDate: r,
      };

      final List<dynamic> result = [];

      // Iterate from lastDate back to startDate, one day at a time
      for (
        var date = lastDate;
        !date.isBefore(startDate);
        date = date.subtract(const Duration(days: 1))
      ) {
        final dateStr = date.toIso8601String().split('T')[0];
        final report = reportByDate[dateStr];

        if (report != null) {
          result.add(report);
        } else {
          result.add({
            'isMissing': true,
            'reportDate': dateStr,
            'projectDay': date.difference(startDate).inDays + 1,
          });
        }
      }

      return result;
    } catch (e) {
      return reports;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/document-1.svg',
            width: 64,
            height: 64,
            colorFilter: const ColorFilter.mode(
              Color(0xFFD0D5DD),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Daily Reports Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep your project updated by creating\nyour first daily report.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF475467)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createNewReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Create Report',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingReportCard(Map<String, dynamic> missingData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  missingData['reportDate'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB42318),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE4E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NO REPORT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB42318),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Project Day: ${missingData['projectDay']}',
              style: const TextStyle(fontSize: 14, color: Color(0xFFB42318)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    _createNewReportForDate(missingData['reportDate']),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFECDCA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Create Report',
                  style: TextStyle(
                    color: Color(0xFFB42318),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(DailyReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewReport(report),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _safeFormatDate(report.reportDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    _buildStatusBadge(report.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Project Day: ${report.projectDay ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475467),
                      ),
                    ),
                    if (report.weatherCondition != null) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(color: Color(0xFFD0D5DD)),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getWeatherIcon(report.weatherCondition),
                        size: 14,
                        color: const Color(0xFF475467),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.weatherCondition!.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475467),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem(
                      Icons.engineering,
                      '${report.activityUpdates.length} Activities',
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.report_problem_outlined,
                      '${report.issues.length} Issues',
                    ),
                    const Spacer(),
                    if (report.status == DailyReportStatus.draft)
                      ElevatedButton(
                        onPressed: () => _submitReport(report),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF276572),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_outlined;
      case 'light_rain':
        return Icons.cloud_outlined;
      case 'heavy_rain':
        return Icons.umbrella_outlined;
      case 'storm':
        return Icons.thunderstorm_outlined;
      case 'extreme_heat':
        return Icons.wb_sunny;
      default:
        return Icons.cloud_queue;
    }
  }

  Future<void> _submitReport(DailyReport report) async {
    try {
      await ref
          .read(dailyReportActionProvider.notifier)
          .submitReport(widget.projectId, report.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        ref.invalidate(dailyReportsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _createNewReportForDate(String date) {
    final scheduleAsync = ref.read(projectScheduleProvider(widget.projectId));

    if (scheduleAsync.hasError ||
        (scheduleAsync.hasValue &&
            (scheduleAsync.value == null ||
                scheduleAsync.value!.phases.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A project schedule must be created before you can log daily reports.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReportFormScreen(
          projectId: widget.projectId,
          initialDate: date,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF667085)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(DailyReportStatus status) {
    Color color;
    Color bgColor;

    switch (status) {
      case DailyReportStatus.draft:
        color = const Color(0xFF71717A);
        bgColor = const Color(0xFFF4F4F5);
        break;
      case DailyReportStatus.submitted:
        color = const Color(0xFF027A48);
        bgColor = const Color(0xFFECFDF3);
        break;
      case DailyReportStatus.reviewed:
        color = const Color(0xFF175CD3);
        bgColor = const Color(0xFFEFF8FF);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    // Implement filter dialog later
  }

  void _createNewReport() {
    final scheduleAsync = ref.read(projectScheduleProvider(widget.projectId));

    if (scheduleAsync.hasError ||
        (scheduleAsync.hasValue &&
            (scheduleAsync.value == null ||
                scheduleAsync.value!.phases.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A project schedule must be created before you can log daily reports.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DailyReportFormScreen(projectId: widget.projectId),
      ),
    );
  }

  void _viewReport(DailyReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReportFormScreen(
          projectId: widget.projectId,
          reportId: report.id,
          initialDate: report.reportDate,
        ),
      ),
    );
  }

  String _safeFormatDate(String dateStr) {
    if (dateStr.isEmpty) return 'No Date';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
