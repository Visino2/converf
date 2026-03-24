import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../features/inspections/models/inspection_models.dart';
import '../../../../features/inspections/providers/inspection_providers.dart';
import 'logging/log_inspection_screen.dart';

class FieldInspectionsModal extends ConsumerWidget {
  final String projectId;
  final bool isEmbedded;

  const FieldInspectionsModal({
    super.key,
    required this.projectId,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionsAsync = ref.watch(inspectionsProvider(projectId));

    if (isEmbedded) {
      return inspectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (response) => _buildContent(context, response.data, ScrollController()),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAECF0),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Expanded(
                child: inspectionsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (response) => _buildContent(context, response.data, scrollController),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, List<Inspection> inspections, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        if (!isEmbedded)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/camera-1.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Field Inspections',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        const Text(
          'Field Inspection Timeline',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Real-time visual verification from verified QA/QC inspectors across active project phases.',
          style: TextStyle(fontSize: 14, color: Color(0xFF475467), height: 1.5),
        ),
        if (inspections.isEmpty) ...[
          const SizedBox(height: 40),
          _buildEmptyState(),
        ] else ...[
          const SizedBox(height: 16),
          _buildAvatarGroup(inspections),
          const SizedBox(height: 24),
          ...inspections.asMap().entries.map((entry) {
            final index = entry.key;
            final i = entry.value;
            final isLast = index == inspections.length - 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildInspectionCard(i, isLast: isLast),
            );
          }),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _logInspection(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
            child: const Text('Log Inspection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _logInspection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogInspectionScreen(projectId: projectId),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No inspections logged yet.', style: TextStyle(color: Color(0xFF667085))),
    );
  }

  Widget _buildAvatarGroup(List<Inspection> inspections) {
    final inspectors = inspections.map((i) => i.inspector).whereType<Map<String, dynamic>>().toList();
    if (inspectors.isEmpty) return const SizedBox();

    // Unique inspectors by name
    final uniqueInspectors = <String, Map<String, dynamic>>{};
    for (var inspector in inspectors) {
      final name = inspector['name']?.toString() ?? 'Unknown';
      uniqueInspectors[name] = inspector;
    }
    final inspectorList = uniqueInspectors.values.toList();

    return Row(
      children: [
        SizedBox(
          width: (20 * inspectorList.length.clamp(0, 4) + 12).toDouble(),
          height: 32,
          child: Stack(
            children: [
              ...List.generate(inspectorList.length.clamp(0, 4), (index) {
                final inspector = inspectorList[index];
                final avatarUrl = inspector['avatar_url']?.toString();
                
                return Positioned(
                  left: index * 20.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: const Color(0xFFF2F4F7),
                    ),
                    child: ClipOval(
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? Image.network(avatarUrl, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 16, color: Color(0xFF667085)),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        if (inspectorList.length > 4) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FBFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Text(
              '+${inspectorList.length - 4}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF101928)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInspectionCard(Inspection inspection, {bool isLast = false}) {
    final dateFormat = DateFormat('MMMM dd, yyyy • HH:mm');
    final dateStr = inspection.inspectionDate.isNotEmpty 
        ? dateFormat.format(DateTime.parse(inspection.inspectionDate)) 
        : 'N/A';
    
    final inspectorName = inspection.inspector?['name']?.toString() ?? 'Unknown Inspector';
    final inspectorRole = inspection.inspector?['role']?.toString() ?? 'QA/QC AUDITOR';
    final avatarUrl = inspection.inspector?['avatar_url']?.toString();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF276572),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFEAECF0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEAECF0)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (inspection.images.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          inspection.images.first,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Phase Overlay
                      if (inspection.phase != null)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PHASE: ${inspection.phase!.toUpperCase()}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      // Multi-Image Indicator
                      if (inspection.images.length > 1)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${inspection.images.length - 1} MORE',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      // Status Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _buildInspectionStatusBadge(inspection.status),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                            child: ClipOval(
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? Image.network(avatarUrl, fit: BoxFit.cover)
                                  : Image.asset('assets/images/musa.png', fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inspectorRole.toUpperCase(), style: const TextStyle(fontSize: 8, color: Color(0xFF98A2B3), fontWeight: FontWeight.bold)),
                              Text(inspectorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(dateStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF101828))),
                      const Text('TIMESTAMP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF98A2B3))),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '"${inspection.summary}"',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475467), height: 1.5),
                        ),
                      ),
                      if (inspection.findings != null) ...[
                        const SizedBox(height: 16),
                        const Text('KEY FINDINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF98A2B3))),
                        const SizedBox(height: 8),
                        Text(inspection.findings!, style: const TextStyle(fontSize: 12, color: Color(0xFF344054))),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildInspectionStatusBadge(String status) {
    Color bg;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'passed':
        bg = const Color(0xFF0F973D);
        icon = Icons.check;
        label = 'Passed';
        break;
      case 'failed':
        bg = const Color(0xFFD92D20);
        icon = Icons.close;
        label = 'Failed';
        break;
      case 'pending':
      default:
        bg = const Color(0xFF9CA3AF);
        icon = Icons.access_time;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
