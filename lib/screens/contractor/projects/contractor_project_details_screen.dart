import 'dart:async';
import 'dart:io';
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
import 'widgets/project_hub_modal.dart';
import 'widgets/animations/bouncing_ball.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_images_modal.dart';
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
  String?
  _optimisticThumbnailPath; // Local file path shown instantly after pick
  List<ProjectImage> _serverCoverImages =
      []; // Images returned directly from upload response

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
          content: Text('This feature unlocks when the project is active.'),
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

          final hasUnlockedStatus = project.status != ProjectStatus.draft;

          // Unlock project tools as soon as the project leaves the tender/draft stage.
          final canAccessProjectHub = hasUnlockedStatus;

          // Note: If project is active/onTrack/atRisk/delayed/completed, it definitely should be unlocked
          // if the current user is the contractor.
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

                  // Hero image with multiple Cover Images support
                  // Show optimistic local image instantly after pick,
                  // then switch to server data once upload completes.
                  Builder(
                    builder: (context) {
                      if (_optimisticThumbnailPath != null) {
                        return GestureDetector(
                          onTap: _updateThumbnail,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_optimisticThumbnailPath!),
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                      return ref
                          .watch(projectDetailsProvider(widget.projectId))
                          .when(
                            skipLoadingOnReload: true,
                            data: (projectResp) {
                              // Always prefer _serverCoverImages first (most recent upload)
                              // then fall back to details endpoint, then empty
                              final coverImages = _serverCoverImages.isNotEmpty
                                  ? _serverCoverImages
                                  : (projectResp.data?.coverImages ?? []);

                              if (coverImages.isEmpty) {
                                return GestureDetector(
                                  onTap: _updateThumbnail,
                                  child: _buildHeroPlaceholder(),
                                );
                              }

                              return Column(
                                children: [
                                  SizedBox(
                                    height: 220,
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          itemCount: coverImages.length,
                                          onPageChanged: (index) {
                                            // Optional: update local state if needed for dots
                                          },
                                          itemBuilder: (context, index) {
                                            final img = coverImages[index];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    child: Image.network(
                                                      '${img.fileUrl}${img.fileUrl.contains('?') ? '&' : '?'}t=${DateTime.now().millisecondsSinceEpoch}',
                                                      height: 220,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) =>
                                                              _buildHeroPlaceholder(),
                                                    ),
                                                  ),
                                                  // Only show delete icon if at limit (3 images)
                                                  // This keeps UI clean for new projects
                                                  if (coverImages.length >= 3)
                                                    Positioned(
                                                      top: 12,
                                                      right: 12,
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            _confirmDeleteThumbnail(
                                                              img,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration:
                                                              const BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black12,
                                                                    blurRadius:
                                                                        4,
                                                                    offset:
                                                                        Offset(
                                                                          0,
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                          child: const Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (img.isPrimary)
                                                    Positioned(
                                                      top: 12,
                                                      left: 12,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF276572,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: const Text(
                                                          'PRIMARY',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        Positioned(
                                          bottom: 12,
                                          right: 12,
                                          child: Row(
                                            children: [
                                              if (coverImages.length < 3) ...[
                                                _buildHeroAction(
                                                  'assets/images/camera.svg',
                                                  'Add',
                                                  _updateThumbnail,
                                                ),
                                                const SizedBox(width: 8),
                                              ] else ...[
                                                // At max capacity - show helpful hint
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.red.shade300,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Max 3 images',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.red.shade700,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              _buildHeroAction(
                                                'assets/images/camera.svg',
                                                'Manage All',
                                                () => showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) =>
                                                      ProjectImagesModal(
                                                        projectId:
                                                            widget.projectId,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Simple page indicator
                                        if (coverImages.length > 1)
                                          Positioned(
                                            bottom: 12,
                                            left: 0,
                                            right: 0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                coverImages.length,
                                                (index) => Container(
                                                  width: 8,
                                                  height: 8,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                      ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => Container(
                              height: 220,
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
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(child: Icon(Icons.error)),
                            ),
                          );
                    },
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ball-in-court card — dynamic via /responsibility endpoint
                  Consumer(
                    builder: (context, ref, _) {
                      final responsibilityAsync = ref.watch(
                        projectResponsibilityProvider(widget.projectId),
                      );
                      return responsibilityAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (e, st) => const SizedBox.shrink(),
                        data: (response) {
                          final responsibility = response.data;
                          // Only show when there are items for the current user
                          if (responsibility == null ||
                              !responsibility.hasItemsForYou) {
                            return const SizedBox.shrink();
                          }

                          final isPending =
                              responsibility.cardStatus == 'pending';
                          final bgColor = isPending
                              ? const Color(0xFFFFF6ED)
                              : const Color(0xFFECFDF5);
                          final borderColor = isPending
                              ? const Color(0xFFFED0AA)
                              : const Color(0xFFA7F3D0);
                          final textColor = isPending
                              ? const Color(0xFFEB460B)
                              : const Color(0xFF027A48);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Red bouncing basketball when pending,
                                    // static green basketball when approved
                                    if (isPending)
                                      const BouncingBall(size: 44)
                                    else
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB5E3C4),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF91D6A8),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.sports_basketball,
                                            color: Color(0xFF027A48),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (isPending)
                                            const Text(
                                              'Ball currently with',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF475467),
                                              ),
                                            ),
                                          if (isPending)
                                            const SizedBox(height: 2),
                                          Text(
                                            responsibility.assigneeLabel,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF101828),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${isPending ? 'Action required:' : 'Update:'} '
                                            '${responsibility.actionText}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),

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
                            () => _openHub(0, canAccessProjectHub),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/calendar-3.svg',
                            'Schedule',
                            1,
                            !canAccessProjectHub,
                            () => _openHub(1, canAccessProjectHub),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/field_inspection.svg',
                            'Inspections',
                            2,
                            !canAccessProjectHub,
                            () => _openHub(2, canAccessProjectHub),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/document-1.svg',
                            'Daily Reports',
                            3,
                            !canAccessProjectHub,
                            () => _openHub(3, canAccessProjectHub),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/document.svg',
                            'Documents',
                            4,
                            !canAccessProjectHub,
                            () => _openHub(4, canAccessProjectHub),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/camera.svg',
                            'Images',
                            5,
                            !canAccessProjectHub,
                            () => _openHub(5, canAccessProjectHub),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/team.svg',
                            'Team',
                            6,
                            !canAccessProjectHub,
                            () => _openHub(6, canAccessProjectHub),
                          ),
                          const SizedBox(width: 4),
                          _buildTabItem(
                            'assets/images/map.svg',
                            'Site',
                            7,
                            false, // Always viewable
                            () => _openHub(7, canAccessProjectHub),
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

    // Check current image count first
    final imagesAsync = ref.read(projectImagesProvider(widget.projectId));
    final images = imagesAsync.asData?.value ?? [];

    // If at 3 images, show deletion interface first
    if (images.length >= 3) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete an Image First'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'You have reached the maximum of 3 cover images. Please delete one to continue:',
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final img = images[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            '${img.fileUrl}?w=50&h=50',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image),
                                ),
                          ),
                        ),
                        title: Text(
                          'Image ${index + 1}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await _confirmDeleteThumbnail(img);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // If under 3 images, proceed with normal upload
    final source = await _showSourceDialog();
    debugPrint('[Contractor] Selected source: $source');
    if (source == null) return;
    try {
      final XFile? image = await ref
          .read(appImagePickerProvider)
          .pickImage(
            source: source,
            imageQuality: 50,
            maxWidth: 1024,
            maxHeight: 1024,
          );
      debugPrint('[Contractor] Image picked: ${image?.path}');

      if (image != null) {
        // Show local image instantly (optimistic update)
        setState(() => _optimisticThumbnailPath = image.path);
        try {
          final uploadedImages = await ref
              .read(projectImageNotifierProvider.notifier)
              .uploadThumbnail(
                projectId: widget.projectId,
                filePath: image.path,
              );

          // Store images from upload response and clear optimistic path
          if (mounted) {
            setState(() {
              _optimisticThumbnailPath = null;
              if (uploadedImages.isNotEmpty) {
                _serverCoverImages = uploadedImages;
              }
            });
            // Defer invalidation to avoid concurrent modification error
            Future.microtask(() {
              if (mounted) {
                ref.invalidate(projectDetailsProvider(widget.projectId));
              }
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thumbnail updated successfully')),
            );
          }
        } catch (uploadErr) {
          // Revert optimistic update on failure
          if (mounted) {
            setState(() => _optimisticThumbnailPath = null);
          }

          String errorMsg = uploadErr.toString().replaceAll('Exception: ', '');

          // Specific handling for site coordinates not configured
          if (errorMsg.contains('site coordinates') ||
              errorMsg.contains('Site Coordinates') ||
              errorMsg.contains('must be configured')) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Site Not Ready'),
                content: const Text(
                  'The project owner needs to configure the site coordinates first. This establishes the geofence and location context for the project. Please check back later.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          // Specific handling for the 3-image limit error
          if (errorMsg.contains('Maximum of 3 cover images')) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Limit Reached'),
                content: const Text(
                  'You already have 3 cover images. Please delete one of the existing thumbnails before uploading a new one.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating thumbnail: $errorMsg')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  Widget _buildHeroPlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF276572).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/images/camera.svg',
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                Color(0xFF276572),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add Project Thumbnail',
            style: TextStyle(
              color: Color(0xFF475467),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Text(
            'Showcase your project with a cover image',
            style: TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAction(String iconPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                Color(0xFF344054),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteThumbnail(ProjectImage image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text(
          'Are you sure you want to remove this project image? This will free up a slot in your 3-image limit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(projectImageNotifierProvider.notifier)
            .deleteThumbnail(
              projectId: widget.projectId,
              coverImageId: image.id,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image removed successfully')),
          );
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

  final List<Map<String, String>> payments = const [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
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
                        projectAsync.when(
                          data: (response) {
                            final p = response.data;
                            return Text(
                              financials.hasContractValue
                                  ? financials.formattedContractValue(
                                      p?.currency ?? '',
                                    )
                                  : (p?.formattedBudget ?? '--'),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (_, _) => const SizedBox(),
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
                              financials.formattedEarnedValue(
                                projectAsync.value?.data?.currency ?? '',
                              ),
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
