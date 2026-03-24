import 'package:flutter/material.dart';
import 'dart:ui';

import '../overview_modal.dart';
import '../phases_modal.dart';
import '../schedule_modal.dart';
import 'package:converf/features/projects/providers/schedule_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../features/projects/providers/project_providers.dart';
import '../../../../../features/projects/providers/project_image_providers.dart';
import '../../../../../features/projects/models/project_image.dart';
import '../../../../../features/projects/models/schedule.dart';
import '../../../../../features/projects/models/project.dart';
import 'bids_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_team_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_documents_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_images_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_daily_reports_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_advisory_modal.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/field_inspections_modal.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _ballController;
  late final Animation<double> _ballRotation;

  @override
  void initState() {
    super.initState();
    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ballRotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ballController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ballController.dispose();
    super.dispose();
  }

  void _rollBall() {
    _ballController.forward(from: 0);
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
              leading: const Icon(Icons.photo_library, color: Color(0xFF276572)),
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
    final source = await _showSourceDialog();
    debugPrint('[ProductOwner] Selected source: $source');
    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      debugPrint('[ProductOwner] Image picked: ${image?.path}');
      if (image != null) {
        await ref.read(projectImageNotifierProvider.notifier).uploadImage(
              projectId: widget.projectId,
              filePath: image.path,
              isPrimary: true,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating thumbnail: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));
    final scheduleAsync = ref.watch(projectScheduleProvider(widget.projectId));
    final financialsAsync = ref.watch(projectFinancialsProvider(widget.projectId));
    final imagesAsync = ref.watch(projectImagesProvider(widget.projectId));
    
    final scheduleId = scheduleAsync.value?.id;
    final phasesAsync = scheduleId != null
        ? ref.watch(schedulePhasesProvider(scheduleId))
        : const AsyncValue<List<SchedulePhase>>.loading();

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
          style: const TextStyle(color: Color(0xFF101828), fontSize: 17, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF667085)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('DEBUG ERROR: $error')),
        data: (projectData) {
          final project = projectData.data;
          if (project == null) return const Center(child: Text('DEBUG: PROJECT DATA IS NULL'));
          
          return ExcludeSemantics(
            child: SafeArea(
              child: SingleChildScrollView(
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
                              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF12B76A)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  project.formattedLocation,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildBadge(project.status.label.toUpperCase(), project.status.bgColor, project.status.textColor),
                            const SizedBox(width: 8),
                            _buildBadge(project.constructionType.toUpperCase(), const Color(0xFFF2F4F7), const Color(0xFF344054)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
  
                    imagesAsync.when(
                      data: (images) {
                        final primaryImage = images.firstWhere(
                          (img) => img.isPrimary,
                          orElse: () => images.isNotEmpty ? images.first : ProjectImage(
                            id: '', projectId: '', fileUrl: '', fileSize: 0, mimeType: '', isPrimary: false,
                            createdAt: DateTime.now(), updatedAt: DateTime.now()
                          ),
                        );
                        return Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              primaryImage.fileUrl.isNotEmpty
                              ? Image.network(
                                  primaryImage.fileUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/lekki-complex.png', 
                                    fit: BoxFit.cover, 
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/lekki-complex.png', 
                                  fit: BoxFit.cover, 
                                ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: _updateThumbnail,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Update Thumbnail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                                ],
                                              ),
                                            ),
                                          ),
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
                      loading: () => Container(height: 220, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)), child: const Center(child: CircularProgressIndicator())),
                      error: (_, __) => Container(height: 220, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)), child: const Center(child: Icon(Icons.error))),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('OVERALL PROGRESS', '68%', progress: 0.68),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: financialsAsync.when(
                            data: (financials) => _buildStatCard(
                              'BUDGET UTILIZED', 
                              '${financials.budgetUtilizedPercentage}%',
                              subtext: '${financials.formattedEarnedValue} / ${financials.formattedContractValue}',
                            ),
                            loading: () => _buildStatCard('BUDGET UTILIZED', '...', subtext: 'Loading...'),
                            error: (_, __) => _buildStatCard('BUDGET UTILIZED', 'Error', subtext: 'N/A'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // 6. Project Advisory
                    ProjectAdvisoryCard(projectId: widget.projectId),
                    const SizedBox(height: 24),

                    // 7. Expanded Navigation Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(14)),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildTabItem('assets/images/home-2.svg', 'Overview', isActive: true, onTapped: () => _showModal(context, OverviewModal(projectId: widget.projectId))),
                            const SizedBox(width: 4),
                            _buildTabItem('assets/images/calendar-3.svg', 'Schedule', isActive: false, onTapped: () => _showModal(context, ScheduleModal(projectId: widget.projectId))),
                            const SizedBox(width: 4),
                            _buildTabItemWithBadge(Icons.gavel, 'Bids', isActive: false, badge: project.status == ProjectStatus.pendingTender ? project.bidsCount : null, onTapped: () => _showModal(context, BidsModal(projectId: widget.projectId))),
                            const SizedBox(width: 4),
                            _buildTabItem('assets/images/field_inspection.svg', 'Inspections', isActive: false, onTapped: () => _showModal(context, FieldInspectionsModal(projectId: widget.projectId))),
                            const SizedBox(width: 4),
                            _buildTabItem('assets/images/document-1.svg', 'Reports', isActive: false, onTapped: () => _showModal(context, ProjectDailyReportsModal(projectId: widget.projectId))),
                            const SizedBox(width: 4),
                            _buildTabItem('assets/images/team.svg', 'Team', isActive: false, onTapped: () => _showModal(context, ProjectTeamModal(projectId: widget.projectId))),
                            const SizedBox(width: 4),
                            _buildTabItem('assets/images/document.svg', 'Documents', isActive: false, onTapped: () => _showModal(context, ProjectDocumentsModal(projectId: widget.projectId))),
                            const SizedBox(width: 4),
                            _buildTabItem('assets/images/camera.svg', 'Images', isActive: false, onTapped: () => _showModal(context, ProjectImagesModal(projectId: widget.projectId))),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF276572),
          unselectedItemColor: Colors.black87,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 1) {
              Navigator.pop(context);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/home.svg',
                  width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn), errorBuilder: (_, __, ___) => const Icon(Icons.home)),
              activeIcon: SvgPicture.asset('assets/images/home.svg',
                  width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn), errorBuilder: (_, __, ___) => const Icon(Icons.home)),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/projects.svg',
                  width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn), errorBuilder: (_, __, ___) => const Icon(Icons.assignment)),
              activeIcon: SvgPicture.asset('assets/images/projects.svg',
                  width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn), errorBuilder: (_, __, ___) => const Icon(Icons.assignment)),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/team.svg',
                  width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn), errorBuilder: (_, __, ___) => const Icon(Icons.group)),
              activeIcon: SvgPicture.asset('assets/images/team.svg',
                  width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn), errorBuilder: (_, __, ___) => const Icon(Icons.group)),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/more.svg',
                  width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn), errorBuilder: (_, __, ___) => const Icon(Icons.more_horiz)),
              activeIcon: SvgPicture.asset('assets/images/more.svg',
                  width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn), errorBuilder: (_, __, ___) => const Icon(Icons.more_horiz)),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
    );
  }


  Widget _buildTabItem(dynamic icon, String label, {required bool isActive, required VoidCallback onTapped}) {
    return _buildTabItemWithBadge(icon, label, isActive: isActive, badge: null, onTapped: onTapped);
  }

  Widget _buildTabItemWithBadge(dynamic icon, String label, {required bool isActive, int? badge, required VoidCallback onTapped}) {
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
                color: isActive ? const Color(0xFF276572) : const Color(0xFF667085),
              )
            else if (icon is String && icon.endsWith('.svg'))
              SvgPicture.asset(
                icon,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                    isActive ? const Color(0xFF276572) : const Color(0xFF667085),
                    BlendMode.srcIn),
                errorBuilder: (context, error, stackTrace) => Icon(
                    isActive ? Icons.circle : Icons.circle_outlined,
                    size: 18,
                    color: isActive ? const Color(0xFF276572) : const Color(0xFF667085)),
              )
            else
              Icon(isActive ? Icons.circle : Icons.circle_outlined,
                  size: 18, color: isActive ? const Color(0xFF276572) : const Color(0xFF667085)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF276572) : const Color(0xFF667085),
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF276572), borderRadius: BorderRadius.circular(20)),
                child: Text('$badge', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }



  Widget _buildStatCard(String label, String value, {double? progress, String? subtext}) {
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
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF667085))),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
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
            Text(subtext, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
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
