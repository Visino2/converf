import 'package:flutter/material.dart';
import 'dart:async';

import '../overview_modal.dart';
import '../schedule_modal.dart';
import '../messages/message_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:converf/core/media/app_image_picker.dart';
import '../../../../../features/projects/providers/project_providers.dart';
import '../../../../../features/phases/providers/phase_providers.dart';
import '../../../../../features/projects/providers/project_image_providers.dart';
import '../../../../../features/projects/models/project_image.dart';
import '../../../../../features/marketplace/providers/marketplace_providers.dart';
import '../../../../../features/projects/providers/schedule_providers.dart';
import 'bids_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_team_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_documents_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_images_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_daily_reports_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/field_inspections_modal.dart';
import 'project_site_modal.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Eagerly fetch the project schedule so the modal opens instantly.
    Future.microtask(() {
      ref.read(projectScheduleProvider(widget.projectId).future).ignore();
    });
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint(
          '[ProjectDetails] Auto-refreshing data for ${widget.projectId}...',
        );
        ref.invalidate(projectDetailsProvider(widget.projectId));
        ref.invalidate(projectFinancialsProvider(widget.projectId));
        ref.invalidate(projectScheduleProvider(widget.projectId));
        ref.invalidate(projectBidsProvider);
        ref.invalidate(projectOpenBidsCountProvider(widget.projectId));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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
    debugPrint('[ProductOwner] Update Thumbnail clicked');

    // Check current cover image count first
    final imagesAsync = ref.read(projectCoverImagesProvider(widget.projectId));
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
    debugPrint('[ProductOwner] Selected source: $source');
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
      debugPrint('[ProductOwner] Image picked: ${image?.path}');
      if (image != null) {
        try {
          await ref
              .read(projectImageNotifierProvider.notifier)
              .uploadThumbnail(
                projectId: widget.projectId,
                filePath: image.path,
              );

          // Add delay to ensure backend has processed the upload
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thumbnail updated successfully')),
            );
            // Refresh project details — cover images derive from it automatically
            ref.invalidate(projectDetailsProvider(widget.projectId));
          }
        } catch (uploadErr) {
          if (mounted) {
            String errorMsg = uploadErr.toString().replaceAll(
              'Exception: ',
              '',
            );

            // Specific handling for site coordinates not configured
            if (errorMsg.contains('site coordinates') ||
                errorMsg.contains('Site Coordinates') ||
                errorMsg.contains('must be configured')) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Setup Site Coordinates'),
                  content: const Text(
                    'Before uploading photos, you need to configure the project site coordinates. This helps establish the geofence and location context for the project.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showModal(
                          context,
                          ProjectSiteModal(projectId: widget.projectId),
                        );
                      },
                      child: const Text('Setup Site'),
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
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $errorMsg')));
      }
    }
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

  Widget _buildHeroPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
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
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Color(0xFF276572),
              size: 32,
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
            'Recommended for a better profile',
            style: TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF276572), size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF276572),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));
    final financialsAsync = ref.watch(
      projectFinancialsProvider(widget.projectId),
    );
    final imagesAsync = ref.watch(projectCoverImagesProvider(widget.projectId));
    final phasesAsync = ref.watch(phasesProvider(widget.projectId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          projectAsync.value?.data?.title ?? 'Project Details',
          style: const TextStyle(
            color: Color(0xFF101828),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Color(0xFF667085)),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load project',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Something went wrong. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(projectDetailsProvider(widget.projectId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (projectData) {
          final project = projectData.data;
          if (project == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_open_outlined, size: 48, color: Color(0xFF667085)),
                    const SizedBox(height: 16),
                    const Text(
                      'Project not found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(projectDetailsProvider(widget.projectId)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276572),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ExcludeSemantics(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Location & Badges Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFF12B76A),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  project.formattedLocation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF667085),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildBadge(
                              project.assignmentMethod == 'self_managed'
                                  ? 'SELF MANAGED'
                                  : project.status.label.toUpperCase(),
                              project.assignmentMethod == 'self_managed'
                                  ? const Color(0xFFF0FBFB)
                                  : project.status.bgColor,
                              project.assignmentMethod == 'self_managed'
                                  ? const Color(0xFF276572)
                                  : project.status.textColor,
                            ),
                            const SizedBox(width: 8),
                            _buildBadge(
                              project.constructionType.toUpperCase(),
                              const Color(0xFFF2F4F7),
                              const Color(0xFF344054),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    imagesAsync.when(
                      data: (images) {
                        final coverImages = images;

                        if (coverImages.isEmpty) {
                          return GestureDetector(
                            onTap: _updateThumbnail,
                            child: Container(
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _buildHeroPlaceholder(),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 220,
                          child: Stack(
                            children: [
                              PageView.builder(
                                itemCount: coverImages.length,
                                itemBuilder: (context, index) {
                                  final img = coverImages[index];
                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0xFFE4E7EC),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          img.fileUrl,
                                          fit: BoxFit.cover,
                                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                            if (wasSynchronouslyLoaded || frame != null) return child;
                                            return AnimatedOpacity(
                                              opacity: 0,
                                              duration: Duration.zero,
                                              child: child,
                                            );
                                          },
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return const _ImageSkeleton();
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildHeroPlaceholder(),
                                        ),
                                        if (img.isPrimary)
                                          Positioned(
                                            top: 12,
                                            left: 12,
                                            child: _buildBadge(
                                              'PRIMARY',
                                              const Color(0xFF276572),
                                              Colors.white,
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
                                                  _confirmDeleteThumbnail(img),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (coverImages.length < 3) ...[
                                        _buildHeroAction(
                                          Icons.camera_alt_outlined,
                                          'Add',
                                          _updateThumbnail,
                                        ),
                                        const SizedBox(width: 8),
                                      ] else ...[
                                        // At max capacity - show helpful hint
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.red.shade300,
                                            ),
                                          ),
                                          child: Text(
                                            'Max 3 images',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      _buildHeroAction(
                                        Icons.apps,
                                        'All',
                                        () => _showModal(
                                          context,
                                          ProjectImagesModal(
                                            projectId: widget.projectId,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (coverImages.length > 1)
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        coverImages.length,
                                        (index) => Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      loading: () => Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(child: Icon(Icons.error)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: phasesAsync.when(
                            data: (phasesResponse) {
                              final phases = phasesResponse.data;
                              final pct = phases.isEmpty
                                  ? 0
                                  : ((phases.where((p) => p.status == 'completed').length /
                                          phases.length) *
                                      100)
                                      .round();
                              return _buildStatCard(
                                'OVERALL PROGRESS',
                                '$pct%',
                                progress: pct / 100,
                              );
                            },
                            loading: () => _buildStatCard('OVERALL PROGRESS', '...'),
                            error: (err, st) => _buildStatCard('OVERALL PROGRESS', '0%', progress: 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: financialsAsync.when(
                            data: (financials) => projectAsync.when(
                              data: (pResponse) {
                                final p = pResponse.data;
                                final currency = p?.currency ?? '';
                                final contractDisplay =
                                    financials.hasContractValue
                                    ? financials.formattedContractValue(
                                        currency,
                                      )
                                    : (p?.formattedBudget ?? '--');

                                return _buildStatCard(
                                  'BUDGET UTILIZED',
                                  '${financials.budgetUtilizedPercentage}%',
                                  subtext:
                                      '${financials.formattedEarnedValue(currency)} / $contractDisplay',
                                );
                              },
                              loading: () => _buildStatCard(
                                'BUDGET UTILIZED',
                                '${financials.budgetUtilizedPercentage}%',
                                subtext: 'Loading...',
                              ),
                              error: (_, _) => _buildStatCard(
                                'BUDGET UTILIZED',
                                '${financials.budgetUtilizedPercentage}%',
                                subtext: 'Error',
                              ),
                            ),
                            loading: () => _buildStatCard(
                              'BUDGET UTILIZED',
                              '...',
                              subtext: 'Loading...',
                            ),
                            error: (error, stackTrace) => _buildStatCard(
                              'BUDGET UTILIZED',
                              'Error',
                              subtext: 'N/A',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 6. Project Advisory
                    // ProjectAdvisoryCard(projectId: widget.projectId),
                    // const SizedBox(height: 24),

                    // 7. Expanded Navigation Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            Consumer(
                              builder: (context, ref, child) => _buildTabItem(
                                'assets/images/home-2.svg',
                                'Overview',
                                isActive: true,
                                onTapped: () {
                                  final scheduleAsync = ref.read(
                                    projectScheduleProvider(widget.projectId),
                                  );
                                  if (scheduleAsync.hasError ||
                                      (scheduleAsync.hasValue &&
                                          (scheduleAsync.value == null ||
                                              scheduleAsync
                                                  .value!
                                                  .phases
                                                  .isEmpty))) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          project.assignmentMethod == 'self_managed'
                                              ? 'Create a project schedule first to view the overview.'
                                              : 'Wait for the contractor to create a project schedule to view the overview.',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                  _showModal(
                                    context,
                                    OverviewModal(projectId: widget.projectId),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildTabItem(
                              'assets/images/calendar-3.svg',
                              'Schedule',
                              isActive: false,
                              onTapped: () => _showModal(
                                context,
                                ScheduleModal(projectId: widget.projectId),
                              ),
                            ),
                            if (project.assignmentMethod != 'self_managed') ...[
                              const SizedBox(width: 12),
                              Consumer(
                                builder: (context, ref, child) {
                                  final openBidsCountAsync = ref.watch(
                                    projectOpenBidsCountProvider(
                                      widget.projectId,
                                    ),
                                  );
                                  final badgeCount =
                                      openBidsCountAsync.asData?.value;
                                  return _buildTabItemWithBadge(
                                    Icons.gavel,
                                    'Bids',
                                    isActive: false,
                                    badge: badgeCount != null && badgeCount > 0
                                        ? badgeCount
                                        : null,
                                    onTapped: () => _showModal(
                                      context,
                                      BidsModal(projectId: widget.projectId),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(width: 12),
                            _buildTabItem(
                              'assets/images/field_inspection.svg',
                              'Inspections',
                              isActive: false,
                              onTapped: () => _showModal(
                                context,
                                FieldInspectionsModal(
                                  projectId: widget.projectId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Consumer(
                              builder: (context, ref, child) => _buildTabItem(
                                'assets/images/document-1.svg',
                                'Reports',
                                isActive: false,
                                onTapped: () {
                                  final scheduleAsync = ref.read(
                                    projectScheduleProvider(widget.projectId),
                                  );
                                  if (scheduleAsync.hasError ||
                                      (scheduleAsync.hasValue &&
                                          (scheduleAsync.value == null ||
                                              scheduleAsync
                                                  .value!
                                                  .phases
                                                  .isEmpty))) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Daily reports will be available once the project schedule is created.',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                  _showModal(
                                    context,
                                    ProjectDailyReportsModal(
                                      projectId: widget.projectId,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildTabItem(
                              'assets/images/team.svg',
                              'Team',
                              isActive: false,
                              onTapped: () => _showModal(
                                context,
                                ProjectTeamModal(projectId: widget.projectId),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildTabItem(
                              'assets/images/document.svg',
                              'Documents',
                              isActive: false,
                              onTapped: () => _showModal(
                                context,
                                ProjectDocumentsModal(
                                  projectId: widget.projectId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildTabItem(
                              'assets/images/camera.svg',
                              'Images',
                              isActive: false,
                              onTapped: () => _showModal(
                                context,
                                ProjectImagesModal(projectId: widget.projectId),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildTabItem(
                              Icons.map_outlined,
                              'Site',
                              isActive: false,
                              onTapped: () => _showModal(
                                context,
                                ProjectSiteModal(projectId: widget.projectId),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildTabItem(
                              'assets/images/message.svg',
                              'Messages',
                              isActive: false,
                              onTapped: () {
                                if (projectAsync.hasValue &&
                                    projectAsync.value!.data != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MessageDetailsScreen(
                                            project: projectAsync.value!.data!,
                                          ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTabItem(
    dynamic icon,
    String label, {
    required bool isActive,
    required VoidCallback onTapped,
  }) {
    return _buildTabItemWithBadge(
      icon,
      label,
      isActive: isActive,
      badge: null,
      onTapped: onTapped,
    );
  }

  Widget _buildTabItemWithBadge(
    dynamic icon,
    String label, {
    required bool isActive,
    int? badge,
    required VoidCallback onTapped,
  }) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0F9FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? Border.all(color: const Color(0xFFBAE6FD)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? const Color(0xFF276572)
                    : const Color(0xFF667085),
              )
            else if (icon is String && icon.endsWith('.svg'))
              SvgPicture.asset(
                icon,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  isActive ? const Color(0xFF276572) : const Color(0xFF667085),
                  BlendMode.srcIn,
                ),
                errorBuilder: (context, error, stackTrace) => Icon(
                  isActive ? Icons.circle : Icons.circle_outlined,
                  size: 18,
                  color: isActive
                      ? const Color(0xFF276572)
                      : const Color(0xFF667085),
                ),
              )
            else
              Icon(
                isActive ? Icons.circle : Icons.circle_outlined,
                size: 18,
                color: isActive
                    ? const Color(0xFF276572)
                    : const Color(0xFF667085),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF276572)
                    : const Color(0xFF667085),
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF276572),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value, {
    double? progress,
    String? subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF2F4F7),
              color: const Color(0xFF12B76A),
              borderRadius: BorderRadius.circular(10),
              minHeight: 6,
            ),
          ],
          if (subtext != null) ...[
            const SizedBox(height: 8),
            Text(
              subtext,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  void _showModal(BuildContext context, Widget modal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => modal,
    );
  }
}

class _ImageSkeleton extends StatefulWidget {
  const _ImageSkeleton();

  @override
  State<_ImageSkeleton> createState() => _ImageSkeletonState();
}

class _ImageSkeletonState extends State<_ImageSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _color = ColorTween(
      begin: const Color(0xFFE4E7EC),
      end: const Color(0xFFF2F4F7),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, _) => ColoredBox(color: _color.value!),
    );
  }
}
