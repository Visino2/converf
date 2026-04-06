import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/projects/providers/project_providers.dart';
import 'package:converf/screens/widgets/maps/site_coordinates_tab.dart';

class ProjectSiteModal extends ConsumerWidget {
  final String projectId;
  final bool canEdit;

  const ProjectSiteModal({
    super.key,
    required this.projectId,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFEAECF0)),
            Expanded(
              child: projectAsync.when(
                data: (response) {
                  final project = response.data;
                  if (project == null) {
                    return const Center(child: Text('Project not found'));
                  }
                  return SiteCoordinatesTab(
                    project: project,
                    canEdit: canEdit,
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF276572)),
                ),
                error: (err, _) => Center(
                  child: Text('Error: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Site Coordinates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF667185)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
