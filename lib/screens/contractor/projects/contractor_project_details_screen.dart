import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../product_owner/widgets/dashboard/messages/message_details_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:converf/core/media/app_image_picker.dart';

import '../../../../features/projects/providers/project_providers.dart';
import '../../../../features/projects/models/project_image.dart';
import '../../../../features/projects/models/project.dart';
import '../../../../features/projects/providers/project_image_providers.dart';
import '../../../../features/projects/providers/schedule_providers.dart';
import 'package:converf/core/api/api_client.dart';
import '../../../../features/profile/providers/profile_providers.dart';
import 'widgets/project_hub_modal.dart';
// To fetch overall team for assignment

class ContractorProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ContractorProjectDetailsScreen({super.key, required this.projectId});

  @override
  ConsumerState<ContractorProjectDetailsScreen> createState() =>
      _ContractorProjectDetailsScreenState();
}

class _ContractorProjectDetailsScreenState
    extends ConsumerState<ContractorProjectDetailsScreen> {
  int _selectedTabIndex = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint(
          '[ContractorProjectDetails] Auto-refreshing data for ${widget.projectId}...',
        );
        ref.invalidate(projectDetailsProvider(widget.projectId));
        ref.invalidate(projectImagesProvider(widget.projectId));
        ref.invalidate(projectScheduleProvider(widget.projectId));
      }
    });
  }

  void _openHub(int index, bool isAssigned) {
    if (!isAssigned && index != 0) {
      // Only Overview (0) is open if not assigned
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This feature will be available once your bid is accepted.',
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(
        projectId: widget.projectId,
        initialTabIndex: index,
        isAssigned: isAssigned,
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));
    final profileAsync = ref.watch(profileProvider);

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
          'Project Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: projectAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF276572)),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (projectData) {
          final project = projectData.data;

          if (project == null) {
            return const Center(child: Text('Project not found'));
          }

          final userId = profileAsync.value?.id.toString();
          final isAssigned =
              project.contractorId == userId &&
              project.status != ProjectStatus.pendingTender &&
              project.status != ProjectStatus.draft;
          // Alternative: if contractorId is not null, they are assigned (or at least selected)
          // But usually we want to check if the CURRENT user is that contractor.

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location & Status badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/map.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF12B76A),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            project.formattedLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475467),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF0C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.status.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: project.status.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (project.constructionType.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                project.constructionType.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF344054),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero image with Update Thumbnail button
                  ref
                      .watch(projectImagesProvider(widget.projectId))
                      .when(
                        data: (images) {
                          final primaryImage = images.firstWhere(
                            (img) => img.isPrimary,
                            orElse: () => images.isNotEmpty
                                ? images.first
                                : ProjectImage(
                                    id: '',
                                    projectId: '',
                                    fileUrl: '',
                                    fileSize: 0,
                                    mimeType: '',
                                    isPrimary: false,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                          );

                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: primaryImage.fileUrl.isNotEmpty
                                    ? Image.network(
                                        primaryImage.fileUrl,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Image.asset(
                                              'assets/images/lekki-complex.png',
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                      )
                                    : Image.asset(
                                        'assets/images/lekki-complex.png', // Temporary placeholder
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => _updateThumbnail(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFEAECF0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/camera.svg',
                                          width: 16,
                                          height: 16,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFF344054),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Update Thumbnail',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) => Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Icon(Icons.error)),
                        ),
                      ),
                  const SizedBox(height: 16),

                  // Action buttons: Update Progress & Submit Milestone
                  /*Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _uploadProgressPhoto(isAssigned),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isAssigned
                                  ? Colors.white
                                  : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isAssigned
                                    ? const Color(0xFFD0D5DD)
                                    : const Color(0xFFEAECF0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Update Progress',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isAssigned
                                          ? const Color(0xFF344054)
                                          : const Color(0xFF98A2B3),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  'assets/images/camera.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    isAssigned
                                        ? const Color(0xFF344054)
                                        : const Color(0xFF98A2B3),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showMilestoneSubmission(isAssigned),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isAssigned
                                  ? const Color(0xFF276572)
                                  : const Color(0xFFEAECF0),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Submit Milestone',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isAssigned
                                          ? Colors.white
                                          : const Color(0xFF98A2B3),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  'assets/images/Target.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    isAssigned
                                        ? Colors.white
                                        : const Color(0xFF98A2B3),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),*/
                  const SizedBox(height: 24),

                  // Client Interface section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Client Interface',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ClipOval(
                              child:
                                  (project.owner?.avatarUrl ??
                                          project.owner?.avatar ??
                                          '')
                                      .isNotEmpty
                                  ? Image.network(
                                      project.owner?.avatarUrl ??
                                          project.owner!.avatar!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                'assets/images/chinedu.png',
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                  : Image.asset(
                                      'assets/images/chinedu.png',
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.owner?.displayName ?? 'Project Owner',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF101828),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xFFFDB022),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    const Text(
                                      '4.9',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475467),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MessageDetailsScreen(project: project),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF276572),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/message.svg',
                                  width: 18,
                                  height: 18,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Message Project',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current Status section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAECF0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Color(0xFF344054),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Current Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          project.description.isNotEmpty
                              ? project.description
                              : 'No description provided.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475467),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFD0D5DD),
                                ),
                              ),
                              child: const Text(
                                '8/12 Phases Complete',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF344054),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFD0D5DD),
                                ),
                              ),
                              child: const Text(
                                '92% Quality Score',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF344054),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ball-in-court card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFEDF89)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE4E2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.error_outline,
                                      size: 20,
                                      color: Color(0xFFD92D20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ball-in-court',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF475467),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'You',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF101828),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF276572),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Address Now',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab section: Overview, Documents, Team, Financial, Bids
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildTabItem(
                            'assets/images/home-2.svg',
                            'Overview',
                            0,
                            false,
                            () => _openHub(0, isAssigned),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/calendar-3.svg',
                            'Schedule',
                            1,
                            !isAssigned,
                            () => _openHub(1, isAssigned),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/field_inspection.svg',
                            'Inspections',
                            2,
                            !isAssigned,
                            () => _openHub(2, isAssigned),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/document-1.svg',
                            'Daily Reports',
                            3,
                            !isAssigned,
                            () => _openHub(3, isAssigned),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/document.svg',
                            'Documents',
                            4,
                            !isAssigned,
                            () => _openHub(4, isAssigned),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/camera.svg',
                            'Images',
                            5,
                            !isAssigned,
                            () => _openHub(5, isAssigned),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/team.svg',
                            'Team',
                            6,
                            !isAssigned,
                            () => _openHub(6, isAssigned),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/map.svg',
                            'Site',
                            7,
                            false, // Always viewable
                            () => _openHub(7, isAssigned),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 12 / 255),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF276572),
          unselectedItemColor: Colors.black87,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/home.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/home.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/projects.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/projects.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/store.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/store.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Marketplace',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/case-1.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/case-1.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Tools',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    String iconPath,
    String label,
    int index,
    bool isLocked,
    VoidCallback onTapped,
  ) {
    bool isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        onTapped();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF9FAFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: isLocked ? 0.5 : 1.0,
              child: SvgPicture.asset(
                iconPath,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  isActive ? const Color(0xFF276572) : const Color(0xFF667085),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isLocked
                    ? const Color(0xFF98A2B3)
                    : (isActive
                          ? const Color(0xFF101828)
                          : const Color(0xFF667085)),
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.lock_outline,
                size: 12,
                color: Color(0xFF98A2B3),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<ImageSource?> _showSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF276572),
              ),
              title: const Text('Photo Library'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF276572)),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _updateThumbnail() async {
    debugPrint('[Contractor] Update Thumbnail clicked');
    final source = await _showSourceDialog();
    debugPrint('[Contractor] Selected source: $source');
    if (source == null) return;
    try {
      final XFile? image = await ref
          .read(appImagePickerProvider)
          .pickImage(
            source: source,
            imageQuality: 70,
            maxWidth: 1920,
            maxHeight: 1080,
          );
      debugPrint('[Contractor] Image picked: ${image?.path}');

      if (image != null) {
        await ref
            .read(projectImageNotifierProvider.notifier)
            .uploadThumbnail(
              projectId: widget.projectId,
              filePath: image.path,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  // ── Modal launchers ──

  // ignore: unused_element
  Future<void> _uploadProgressPhoto(bool isAssigned) async {
    if (!isAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You can upload progress photos once your bid is accepted.',
          ),
        ),
      );
      return;
    }
    debugPrint('[Contractor] Upload Progress clicked');
    final source = await _showSourceDialog();
    debugPrint('[Contractor] Selected source: $source');
    if (source == null) return;
    try {
      final XFile? image = await ref
          .read(appImagePickerProvider)
          .pickImage(
            source: source,
            imageQuality: 70,
            maxWidth: 1920,
            maxHeight: 1080,
          );
      debugPrint('[Contractor] Progress Image picked: ${image?.path}');
      if (image != null) {
        await ref
            .read(projectImageNotifierProvider.notifier)
            .uploadImage(
              projectId: widget.projectId,
              filePath: image.path,
              isPrimary: false, // Progress photo, not primary thumbnail
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progress photo uploaded successfully'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  // ignore: unused_element
  void _showMilestoneSubmission(bool isAssigned) {
    if (!isAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Milestone submission is available once your bid is accepted.',
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FinancialModal(projectId: widget.projectId),
    );
  }
}

// ── Financial Modal ──
class _FinancialModal extends ConsumerWidget {
  final String projectId;
  const _FinancialModal({required this.projectId});

  final List<Map<String, String>> payments = const [
    {'amount': '₦4.2M', 'status': 'Pending', 'date': '4/21/12'},
    {'amount': '₦4.2M', 'status': 'Paid', 'date': '4/4/18'},
    {'amount': '₦4.2M', 'status': 'Paid', 'date': '4/4/18'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(projectScheduleProvider(projectId));
    final financialsAsync = ref.watch(projectFinancialsProvider(projectId));

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    SvgPicture.asset(
                      'assets/images/financial.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF276572),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Financial',
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
            // Financial Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF276572),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  financialsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (error, stackTrace) => const Text(
                      'Error loading financials',
                      style: TextStyle(color: Colors.white70),
                    ),
                    data: (financials) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Contract Value',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          financials.formattedContractValue,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Earned',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      scheduleAsync.when(
                        loading: () => const SizedBox(),
                        error: (error, stackTrace) {
                          final errStr = error.toString().toLowerCase();
                          bool isNotFound = false;
                          if (error is ApiException &&
                              error.statusCode == 404) {
                            isNotFound = true;
                          }
                          if (errStr.contains('404') ||
                              errStr.contains('no query results')) {
                            isNotFound = true;
                          }

                          return Text(
                            isNotFound ? 'No Schedule' : 'Error',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          );
                        },
                        data: (schedule) {
                          final currentPhase = schedule.phases.isNotEmpty
                              ? schedule.phases.first.name
                              : 'N/A';
                          return Text(
                            currentPhase,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4AC3C9),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  scheduleAsync.when(
                    loading: () => Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    error: (error, stackTrace) => Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    data: (schedule) {
                      final completedCount = schedule.phases
                          .where((p) => p.status == 'completed')
                          .length;
                      final totalCount = schedule.phases.length;
                      final progress = totalCount > 0
                          ? completedCount / totalCount
                          : 0.0;
                      return Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4AC3C9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  financialsAsync.when(
                    loading: () => const SizedBox(),
                    error: (error, stackTrace) => const SizedBox(),
                    data: (financials) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Budget Utilized',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${financials.budgetUtilizedPercentage}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Earned Value',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              financials.formattedEarnedValue,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Payment Schedule Table
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    color: const Color(0xFFF9FAFB),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475467),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475467),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Date',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475467),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...payments.map(
                    (p) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFEAECF0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              p['amount']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: p['status'] == 'Paid'
                                      ? const Color(0xFFECFDF3)
                                      : const Color(0xFFFFFAEB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  p['status']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: p['status'] == 'Paid'
                                        ? const Color(0xFF027A48)
                                        : const Color(0xFFB4543E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              p['date']!,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475467),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276572),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add Milestone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
