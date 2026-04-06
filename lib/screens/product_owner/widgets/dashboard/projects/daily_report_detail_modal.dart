import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../features/daily_reports/models/daily_report_models.dart';
import '../../../../../features/daily_reports/providers/daily_report_providers.dart';

class DailyReportDetailModal extends ConsumerWidget {
  final String projectId;
  final String reportId;

  const DailyReportDetailModal({
    super.key,
    required this.projectId,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(dailyReportDetailProvider((
      projectId: projectId,
      reportId: reportId,
    )));

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D5DD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Report Details',
                  style: TextStyle(
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
                    child: const Icon(Icons.close, size: 20, color: Color(0xFF667085)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: reportAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF276572)),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (report) => SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewHeader(report),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Site Conditions'),
                    _buildSiteConditions(report),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Resources & Labor'),
                    _buildResources(report),
                    const SizedBox(height: 24),
                    if (report.activityUpdates.isNotEmpty) ...[
                      _buildSectionHeader('Activity Updates'),
                      _buildActivityUpdates(report),
                      const SizedBox(height: 24),
                    ],
                    if (report.issues.isNotEmpty) ...[
                      _buildSectionHeader('Issues & Barriers'),
                      _buildIssues(report),
                      const SizedBox(height: 24),
                    ],
                    if (report.tomorrowPlan.isNotEmpty) ...[
                      _buildSectionHeader('Tomorrow\'s Plan'),
                      _buildTomorrowPlan(report),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 32),
                    _buildExportActions(context, ref, report),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader(DailyReport report) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.assignment, color: Color(0xFF276572), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(report.reportDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(report.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(report.status),
                      ),
                    ),
                  ),
                  if (report.projectDay != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Day ${report.projectDay}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D2939),
        ),
      ),
    );
  }

  Widget _buildSiteConditions(DailyReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Weather',
            report.weatherCondition?.replaceAll('_', ' ') ?? 'Fair',
            icon: Icons.wb_sunny_outlined,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Temperature',
            '${report.temperatureC ?? 'N/A'}°C',
            icon: Icons.thermostat_outlined,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Site Accessible',
            report.siteAccessible == true ? 'Yes' : 'No',
            icon: Icons.door_front_door_outlined,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Weather Stoppage',
            report.weatherStoppage == true ? 'Yes (${report.weatherHoursLost}h lost)' : 'No',
            icon: Icons.timer_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildResources(DailyReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResourceItem('Labor', report.laborCount?.toString() ?? '0', Icons.people_outline),
          _buildResourceItem('Equipment', report.equipmentOperatingCount?.toString() ?? '0', Icons.precision_manufacturing_outlined),
          _buildResourceItem('Deliveries', report.deliveriesCount?.toString() ?? '0', Icons.local_shipping_outlined),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667085), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
      ],
    );
  }

  Widget _buildActivityUpdates(DailyReport report) {
    return Column(
      children: report.activityUpdates.map((update) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEAECF0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Activity ID: ${update.projectActivityId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                  ),
                ),
                Text(
                  '${update.actualPct}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF276572)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (double.tryParse(update.actualPct) ?? 0) / 100,
              backgroundColor: const Color(0xFFF2F4F7),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF276572)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildIssues(DailyReport report) {
    return Column(
      children: report.issues.map((issue) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFEE4E2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFD92D20), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.issueType.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB42318)),
                  ),
                  const SizedBox(height: 4),
                  if (issue.resolutionNote != null)
                    Text(
                      issue.resolutionNote!,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF475467)),
                    ),
                  if (issue.impactDays.isNotEmpty && issue.impactDays != '0')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Impact: ${issue.impactDays} days',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB42318)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildTomorrowPlan(DailyReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: report.tomorrowPlan.map((plan) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF667085)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Activity ${plan.projectActivityId}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF344054)),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildExportActions(BuildContext context, WidgetRef ref, DailyReport report) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleExport(context, ref, projectId, report.id, 'pdf'),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: Colors.white),
            label: const Text('Export PDF', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleExport(context, ref, projectId, report.id, 'xlsx'),
            icon: const Icon(Icons.table_view_outlined, size: 18, color: Color(0xFF276572)),
            label: const Text('Export Excel', style: TextStyle(color: Color(0xFF276572))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD0D5DD)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref, String projectId, String reportId, String format) async {
    try {
      if (format == 'pdf') {
        await ref.read(dailyReportActionProvider.notifier).exportPdf(projectId, reportId);
      } else {
        await ref.read(dailyReportActionProvider.notifier).exportXlsx(projectId, reportId);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exporting to $format...')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: const Color(0xFF667085)),
          const SizedBox(width: 12),
        ],
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF667085))),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Color _getStatusBgColor(DailyReportStatus status) {
    switch (status) {
      case DailyReportStatus.submitted: return const Color(0xFFFFFAEB);
      case DailyReportStatus.reviewed: return const Color(0xFFECFDF3);
      default: return const Color(0xFFF2F4F7);
    }
  }

  Color _getStatusTextColor(DailyReportStatus status) {
    switch (status) {
      case DailyReportStatus.submitted: return const Color(0xFFB54708);
      case DailyReportStatus.reviewed: return const Color(0xFF027A48);
      default: return const Color(0xFF667085);
    }
  }
}
