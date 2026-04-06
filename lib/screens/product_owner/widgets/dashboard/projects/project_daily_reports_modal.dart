import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/daily_reports/models/daily_report_models.dart';
import '../../../../../features/daily_reports/providers/daily_report_providers.dart';
import 'package:intl/intl.dart';
import 'daily_report_detail_modal.dart';

class ProjectDailyReportsModal extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectDailyReportsModal({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDailyReportsModal> createState() =>
      _ProjectDailyReportsModalState();
}

class _ProjectDailyReportsModalState
    extends ConsumerState<ProjectDailyReportsModal> {
  DailyReportStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(dailyReportsProvider((
      projectId: widget.projectId,
      status: _filterStatus?.name,
    )));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                    ),
                  ),
                ],
              ),
            ),
            // Status Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All', null),
                    const SizedBox(width: 8),
                    _filterChip('Submitted', DailyReportStatus.submitted),
                    const SizedBox(width: 8),
                    _filterChip('Reviewed', DailyReportStatus.reviewed),
                  ],
                ),
              ),
            ),
            // List
            Expanded(
              child: reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (response) {
                  // Product Owners only see submitted and reviewed reports.
                  // Drafts are always hidden — the Draft filter chip is intentionally absent.
                  final allReports = response.data.where((r) =>
                    r.status == DailyReportStatus.submitted ||
                    r.status == DailyReportStatus.reviewed,
                  ).toList();
                  final reports = _filterStatus == null
                      ? allReports
                      : allReports.where((r) => r.status == _filterStatus).toList();

                  if (reports.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(dailyReportsProvider),
                      child: ListView(
                        controller: controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 80, horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.assignment_outlined, size: 56, color: Color(0xFFD0D5DD)),
                                SizedBox(height: 12),
                                Text('No reports filed yet', 
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF667085))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(dailyReportsProvider),
                    child: ListView.builder(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: reports.length,
                      itemBuilder: (_, i) => _buildReportCard(reports[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, DailyReportStatus? status) {
    final isActive = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF276572) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? const Color(0xFF276572) : const Color(0xFFD0D5DD)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF667085),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(DailyReport report) {
    Color statusColor;
    Color statusBg;
    switch (report.status) {
      case DailyReportStatus.submitted:
        statusColor = const Color(0xFFB54708);
        statusBg = const Color(0xFFFFFAEB);
        break;
      case DailyReportStatus.reviewed:
        statusColor = const Color(0xFF027A48);
        statusBg = const Color(0xFFECFDF3);
        break;
      default:
        statusColor = const Color(0xFF667085);
        statusBg = const Color(0xFFF2F4F7);
    }

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DailyReportDetailModal(
            projectId: widget.projectId,
            reportId: report.id,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEAECF0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment, color: Color(0xFF276572), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _safeFormatDate(report.reportDate),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF101828)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
              child: Text(
                report.status.name.toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ),
          ],
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
