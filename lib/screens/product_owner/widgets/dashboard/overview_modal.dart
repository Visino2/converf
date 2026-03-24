import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/providers/project_providers.dart';
import 'package:converf/features/projects/providers/schedule_providers.dart';
import 'package:intl/intl.dart';
import 'package:converf/core/api/api_client.dart';

class OverviewModal extends ConsumerWidget {
  final String projectId;
  const OverviewModal({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    final scheduleAsync = ref.watch(projectScheduleProvider(projectId));

    return projectAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (response) {
        final project = response.data;
        if (project == null) return const Center(child: Text('Project not found'));
        
        return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/images/home-2.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Project Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475467),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Project Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const Divider(height: 24, color: Color(0xFFEAECF0)),
            _buildDetailRow('Project Owner', project.owner?.displayName ?? 'Not Assigned'),
            const SizedBox(height: 16),
            _buildDetailRow('Start Date', project.formattedDates.split(' - ').first),
            const SizedBox(height: 16),
            _buildDetailRow('Expected Completion', project.formattedDates.split(' - ').last),
            const SizedBox(height: 16),
            _buildDetailRow('Location', project.formattedLocation),
            const SizedBox(height: 24),
            scheduleAsync.when(
              loading: () => const SizedBox(),
              error: (error, stackTrace) {
                final errStr = error.toString().toLowerCase();
                bool isNotFound = false;
                if (error is ApiException && error.statusCode == 404) isNotFound = true;
                if (errStr.contains('404') || errStr.contains('no query results')) isNotFound = true;
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    isNotFound ? 'No schedule has been created yet' : 'Schedule details not available (Error)',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF667085), fontStyle: FontStyle.italic),
                  ),
                );
              },
              data: (schedule) {
                final currentPhase = schedule.phases.isNotEmpty ? schedule.phases.first.name : 'Not started';
                final completedCount = schedule.phases.where((p) => p.status == 'completed').length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFEAECF0)),
                    _buildDetailRow('Current Phase', currentPhase),
                    const SizedBox(height: 16),
                    _buildDetailRow('Phases Completed', '$completedCount of ${schedule.phases.length}'),
                    const SizedBox(height: 16),
                    _buildDetailRowStatus('Schedule Status', schedule.statusLabel),
                    const SizedBox(height: 16),
                    if (schedule.updatedAt.isNotEmpty)
                       _buildDetailRow('Last Activity', DateFormat('MMM d, y').format(DateTime.tryParse(schedule.updatedAt) ?? DateTime.now())),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowStatus(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 12.3,
              height: 17.5 / 12.3,
              color: Color(0xFFEA580C),
            ),
          ),
        ),
      ],
    );
  }
}
