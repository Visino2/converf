import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../product_owner/widgets/dashboard/overview_modal.dart';
import '../../product_owner/widgets/dashboard/messages/message_details_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../features/projects/providers/project_providers.dart';
import '../../../../features/projects/providers/project_document_providers.dart';
import '../../../../features/projects/models/project_document.dart';
import '../../../../features/projects/models/project_image.dart';
import '../../../../features/projects/providers/project_image_providers.dart';
import '../../../../features/projects/providers/project_team_providers.dart';
import '../../../../features/team/providers/team_providers.dart';
import '../../../../features/projects/providers/bidding_providers.dart';
import '../../../../features/projects/providers/schedule_providers.dart';
import 'package:intl/intl.dart';
import 'package:converf/core/api/api_client.dart';
import 'widgets/project_hub_modal.dart';
 // To fetch overall team for assignment

class ContractorProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ContractorProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ContractorProjectDetailsScreen> createState() => _ContractorProjectDetailsScreenState();
}

class _ContractorProjectDetailsScreenState extends ConsumerState<ContractorProjectDetailsScreen> {
  int _selectedTabIndex = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: ref.watch(projectDetailsProvider(widget.projectId)).when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
        error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
        data: (projectData) {
          final project = projectData.data;

          if (project == null) {
            return const Center(child: Text('Project not found'));
          }

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
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),

                  // Location & Status badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/images/map.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Color(0xFF12B76A), BlendMode.srcIn)),
                          const SizedBox(width: 4),
                          Text(project.formattedLocation, style: const TextStyle(fontSize: 14, color: Color(0xFF475467))),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFEF0C7), borderRadius: BorderRadius.circular(12)),
                            child: Text(project.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: project.status.color)),
                          ),
                          const SizedBox(width: 8),
                          if (project.constructionType.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12)),
                              child: Text(project.constructionType.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF344054))),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero image with Update Thumbnail button
                  ref.watch(projectImagesProvider(widget.projectId)).when(
                    data: (images) {
                      final primaryImage = images.firstWhere(
                        (img) => img.isPrimary,
                        orElse: () => images.isNotEmpty ? images.first : ProjectImage(
                          id: '', projectId: '', fileUrl: '', fileSize: 0, mimeType: '', isPrimary: false,
                          createdAt: DateTime.now(), updatedAt: DateTime.now()
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
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFEAECF0)),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset('assets/images/camera.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Color(0xFF344054), BlendMode.srcIn)),
                                    const SizedBox(width: 8),
                                    const Text('Update Thumbnail', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                      child: const Center(child: CircularProgressIndicator()),
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _uploadProgressPhoto,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFD0D5DD)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Flexible(
                              child: Text('Update Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054)), overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset('assets/images/camera.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Color(0xFF344054), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showMilestoneSubmission,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF276572),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Flexible(
                              child: Text('Submit Milestone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset('assets/images/Target.svg', width: 16, height: 16, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Client Interface', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                        Row(
                          children: [
                            ClipOval(
                              child: Image.asset('assets/images/chinedu.png', width: 36, height: 36, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Chinedu Okafor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828))),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFDB022), size: 14),
                                    const SizedBox(width: 2),
                                    const Text('4.9', style: TextStyle(fontSize: 12, color: Color(0xFF475467))),
                                  ],
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
                              builder: (context) => MessageDetailsScreen(project: project),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF276572),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/images/message.svg', width: 18, height: 18, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                            const SizedBox(width: 8),
                            const Text('Message Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
                          child: const Icon(Icons.info_outline, size: 20, color: Color(0xFF344054)),
                        ),
                        const SizedBox(width: 12),
                        const Text('Current Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      project.description.isNotEmpty ? project.description : 'No description provided.',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF475467), height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD0D5DD)),
                          ),
                          child: const Text('8/12 Phases Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF344054))),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD0D5DD)),
                          ),
                          child: const Text('92% Quality Score', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF344054))),
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
                                child: const Icon(Icons.error_outline, size: 20, color: Color(0xFFD92D20)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ball-in-court', style: TextStyle(fontSize: 14, color: Color(0xFF475467))),
                                  const SizedBox(height: 2),
                                  const Text('You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Address Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
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
                  boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildTabItem('assets/images/home-2.svg', 'Overview', 0, () => _openHub(0)),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/calendar-3.svg', 'Schedule', 1, () => _openHub(1)),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/field_inspection.svg', 'Inspections', 2, () => _openHub(2)),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/document-1.svg', 'Daily Reports', 3, () => _openHub(3)),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/document.svg', 'Documents', 4, () => _openHub(4)),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/camera.svg', 'Images', 5, () => _openHub(5)),
                      const SizedBox(width: 4),
                      _buildTabItem('assets/images/team.svg', 'Team', 6, () => _openHub(6)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 12 / 255), blurRadius: 10, offset: const Offset(0, -5))],
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
            if (index == 0) Navigator.popUntil(context, (route) => route.isFirst);
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/home.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/home.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/projects.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/projects.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/target-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/target-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Milestone',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/case-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
              activeIcon: SvgPicture.asset('assets/images/case-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
              label: 'Tools',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String iconPath, String label, int index, VoidCallback onTapped) {
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
            SvgPicture.asset(
              iconPath,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                isActive ? const Color(0xFF276572) : const Color(0xFF667085),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF101828) : const Color(0xFF667085),
              ),
            ),
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
    debugPrint('[Contractor] Update Thumbnail clicked');
    final source = await _showSourceDialog();
    debugPrint('[Contractor] Selected source: $source');
    if (source == null) return;
    try {
      final XFile? image = await _picker.pickImage(source: source);
      debugPrint('[Contractor] Image picked: ${image?.path}');
      
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
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  // ── Modal launchers ──

  void _openHub(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: widget.projectId, initialTabIndex: index),
    );
  }

  void _showOverviewModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: widget.projectId, initialTabIndex: 0),
    );
  }

  void _showDocumentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: widget.projectId, initialTabIndex: 2),
    );
  }

  Future<void> _uploadProgressPhoto() async {
    debugPrint('[Contractor] Upload Progress clicked');
    final source = await _showSourceDialog();
    debugPrint('[Contractor] Selected source: $source');
    if (source == null) return;
    try {
      final XFile? image = await _picker.pickImage(source: source);
      debugPrint('[Contractor] Progress Image picked: ${image?.path}');
      if (image != null) {
        await ref.read(projectImageNotifierProvider.notifier).uploadImage(
              projectId: widget.projectId,
              filePath: image.path,
              isPrimary: false, // Progress photo, not primary thumbnail
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Progress photo uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  void _showTeamModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TeamModal(projectId: widget.projectId),
    );
  }

  void _showFinancialModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FinancialModal(projectId: widget.projectId),
    );
  }

  void _showDailyReports() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: widget.projectId, initialTabIndex: 3),
    );
  }

  void _showFieldInspections() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: widget.projectId, initialTabIndex: 4),
    );
  }

  void _showMilestoneSubmission() {
    // Navigate to project schedule/milestone view or show modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FinancialModal(projectId: widget.projectId),
    );
  }

  void _showBidsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BidsModal(projectId: widget.projectId),
    );
  }

  void _showScheduleScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: widget.projectId, initialTabIndex: 1),
    );
  }
}

// ── Bids Modal ──
class _BidsModal extends ConsumerStatefulWidget {
  final String projectId;
  const _BidsModal({required this.projectId});

  @override
  ConsumerState<_BidsModal> createState() => _BidsModalState();
}

class _BidsModalState extends ConsumerState<_BidsModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _proposalController = TextEditingController();

  Future<void> _submitBid() async {
    if (_amountController.text.isEmpty || _proposalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both amount and proposal')),
      );
      return;
    }
    if (_proposalController.text.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposal must be at least 20 characters long')),
      );
      return;
    }
    try {
      final amount = double.parse(_amountController.text);
      await ref.read(biddingNotifierProvider.notifier).submitBid(
        projectId: widget.projectId,
        amount: amount,
        proposal: _proposalController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting bid: $e')),
        );
      }
    }
  }

  Future<void> _handleBidAction(String bidId, bool accept) async {
    try {
      if (accept) {
        await ref.read(biddingNotifierProvider.notifier).acceptBid(bidId, widget.projectId);
      } else {
        await ref.read(biddingNotifierProvider.notifier).rejectBid(bidId, widget.projectId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bid ${accept ? 'accepted' : 'rejected'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));
    final bidsAsync = ref.watch(projectBidsProvider(widget.projectId));
    final isActionLoading = ref.watch(biddingNotifierProvider).isLoading;

    return SafeArea(
      bottom: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: projectAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (projectResponse) {
            final project = projectResponse.data;
            // Simplified check: if contractor_id is null, it might be in bidding phase
            // Real logic might depend on project.status == 'pending_tender'
            bool canSubmitBid = project?.contractorId == null; 
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/images/target-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
                        const SizedBox(width: 12),
                        const Text('Bidding', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (canSubmitBid) ...[
                  const Text('Submit your Bid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₦ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _proposalController,
                    decoration: const InputDecoration(
                      labelText: 'Proposal',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isActionLoading ? null : _submitBid,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF276572)),
                      child: isActionLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Bid', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const Divider(height: 32),
                ],
                const Text('All Bids', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Expanded(
                  child: bidsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (bids) {
                      if (bids.isEmpty) {
                        return const Center(child: Text('No bids yet.'));
                      }
                  return ListView.builder(
                    itemCount: bids.length,
                    itemBuilder: (context, index) {
                      final bid = bids[index];
                      final isPending = bid.status == 'pending';
                      final isAccepted = bid.status == 'accepted';
                      final isRejected = bid.status == 'rejected';
                      final isShortlisted = bid.status == 'shortlisted';

                      Color statusBgColor = Colors.grey.shade50;
                      Color statusTextColor = Colors.grey;
                      Color borderColor = Colors.grey.shade200;

                      if (isAccepted) {
                        statusBgColor = const Color(0xFFE7F6EC);
                        statusTextColor = const Color(0xFF0F973D);
                        borderColor = const Color(0xFFABEFC6);
                      } else if (isRejected) {
                        statusBgColor = const Color(0xFFFBEAE9);
                        statusTextColor = const Color(0xFFD42620);
                        borderColor = const Color(0xFFFCCDCA);
                      } else if (isShortlisted) {
                        statusBgColor = const Color(0xFFF0FBFB);
                        statusTextColor = const Color(0xFF309DAA);
                        borderColor = const Color(0xFFB7E7EA);
                      } else if (isPending) {
                        statusBgColor = const Color(0xFFFEF6E7);
                        statusTextColor = const Color(0xFF865503);
                        borderColor = const Color(0xFFFEDF89);
                      }

                      final contractorName = bid.contractor?.companyName ?? 
                          '${bid.contractor?.firstName ?? ''} ${bid.contractor?.lastName ?? ''}'.trim();
                      final submittedText = DateFormat.yMMMd().format(bid.createdAt);

                      return Container(
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contractorName.isEmpty ? 'Unknown Contractor' : contractorName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF101828)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      submittedText,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Text(
                                    bid.status.toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusTextColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ((project?.currency ?? 'NGN') == 'NGN') ? '₦ ${bid.amount}' : '${project?.currency ?? 'NGN'} ${bid.amount}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF101828)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Bid Proposal'),
                                        content: SingleChildScrollView(child: Text(bid.proposal)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text('View Proposal', style: TextStyle(decoration: TextDecoration.underline, fontSize: 14, color: Color(0xFF667085))),
                                ),
                              ],
                            ),
                            if (isPending) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: isActionLoading ? null : () => _handleBidAction(bid.id, false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFD42620),
                                        side: const BorderSide(color: Color(0xFFFCCDCA)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isActionLoading ? null : () => _handleBidAction(bid.id, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF276572),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Accept', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  ),
);
}
}

// ── Team Modal ──
class _TeamModal extends ConsumerStatefulWidget {
  final String projectId;
  const _TeamModal({required this.projectId});

  @override
  ConsumerState<_TeamModal> createState() => _TeamModalState();
}

class _TeamModalState extends ConsumerState<_TeamModal> {
  final List<Map<String, String>> staticTeamMembers = const [
    {'name': 'Olamide Akintan', 'role': 'Project Manager', 'avatar': 'assets/images/olamide.png'},
    {'name': 'Alison David', 'role': 'Site Engineer', 'avatar': 'assets/images/alison.png'},
    {'name': 'Megan Willow', 'role': 'Structural Engineer', 'avatar': 'assets/images/megan.png'},
    {'name': 'Janelle Levi', 'role': 'Architect', 'avatar': 'assets/images/janelle.png'},
  ];

  Future<void> _removeMember(String memberId) async {
    try {
      await ref.read(projectTeamNotifierProvider.notifier).removeMember(
        widget.projectId,
        memberId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member removed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing member: $e')),
        );
      }
    }
  }

  Future<void> _showAssignMemberDialog() async {
    final teamAsync = ref.read(teamMembersProvider((projectId: null, page: 1, perPage: 100)));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Team Member'),
        content: teamAsync.when(
          data: (teamResponse) {
            final members = teamResponse.data;
            if (members.isEmpty) {
              return const Text('No team members found.');
            }
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    leading: ClipOval(
                      child: member.user?.avatar != null
                          ? Image.network(member.user!.avatar!, width: 32, height: 32, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person))
                          : const Icon(Icons.person),
                    ),
                    title: Text(member.displayName),
                    subtitle: Text(member.role),
                    onTap: () async {
                      Navigator.pop(context);
                      await _assignMember(member.id);
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading team: $e'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignMember(String teamMemberId) async {
    try {
      await ref.read(projectTeamNotifierProvider.notifier).assignMember(
        widget.projectId,
        teamMemberId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member assigned successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning member: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamAsync = ref.watch(projectTeamProvider(widget.projectId));
    final isActionLoading = ref.watch(projectTeamNotifierProvider).isLoading;

    return SafeArea(
      bottom: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                    SvgPicture.asset('assets/images/group.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
                    const SizedBox(width: 12),
                    const Text('Team', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: isActionLoading ? null : _showAssignMemberDialog,
                      icon: const Icon(Icons.person_add_outlined, color: Color(0xFF276572)),
                      tooltip: 'Assign Member',
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
              ],
            ),
            const SizedBox(height: 24),
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: const Color(0xFFF9FAFB),
              child: const Row(
                children: [
                  SizedBox(width: 20),
                  SizedBox(width: 12),
                  Expanded(child: Text('Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                  Expanded(child: Text('Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                  SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: teamAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (members) {
                  if (members.isEmpty) {
                    return const Center(child: Text('No team members assigned.'));
                  }
                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFD0D5DD)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: member.avatarUrl != null
                                        ? Image.network(
                                            member.avatarUrl!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                                              child: const Icon(Icons.person, color: Color(0xFF98A2B3)),
                                            ),
                                          )
                                        : Container(
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                                            child: const Icon(Icons.person, color: Color(0xFF98A2B3)),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(child: Text(member.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828)))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(member.displayRole, style: const TextStyle(fontSize: 14, color: Color(0xFF475467))),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'remove') {
                                  _removeMember(member.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'remove', child: Text('Remove from Project', style: TextStyle(color: Colors.red))),
                              ],
                              icon: const Icon(Icons.more_vert, color: Color(0xFF667085)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
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
                    SvgPicture.asset('assets/images/financial.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
                    const SizedBox(width: 12),
                    const Text('Financial', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
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
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    error: (_, __) => const Text('Error loading financials', style: TextStyle(color: Colors.white70)),
                    data: (financials) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Contract Value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text(financials.formattedContractValue, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Earned', style: TextStyle(fontSize: 14, color: Colors.white70)),
                       scheduleAsync.when(
                         loading: () => const SizedBox(),
                         error: (error, __) {
                           final errStr = error.toString().toLowerCase();
                           bool isNotFound = false;
                           if (error is ApiException && error.statusCode == 404) isNotFound = true;
                           if (errStr.contains('404') || errStr.contains('no query results')) isNotFound = true;
                           
                           return Text(isNotFound ? 'No Schedule' : 'Error', 
                             style: const TextStyle(fontSize: 14, color: Colors.white70));
                         },
                         data: (schedule) {
                           final currentPhase = schedule.phases.isNotEmpty ? schedule.phases.first.name : 'N/A';
                           return Text(currentPhase, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4AC3C9)));
                         },
                       ),
                    ],
                  ),
                  const SizedBox(height: 12),
                   scheduleAsync.when(
                     loading: () => Container(height: 8, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
                     error: (_, __) => Container(height: 8, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
                     data: (schedule) {
                      final completedCount = schedule.phases.where((p) => p.status == 'completed').length;
                      final totalCount = schedule.phases.length;
                      final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
                      return Stack(
                        children: [
                          Container(height: 8, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF4AC3C9), borderRadius: BorderRadius.circular(4))),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  financialsAsync.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (financials) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Budget Utilized', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text('${financials.budgetUtilizedPercentage}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Earned Value', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(financials.formattedEarnedValue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    color: const Color(0xFFF9FAFB),
                    child: const Row(
                      children: [
                        Expanded(child: Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                        Expanded(child: Center(child: Text('Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467))))),
                        Expanded(child: Text('Date', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
                      ],
                    ),
                  ),
                  ...payments.map((p) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(p['amount']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF101828)))),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: p['status'] == 'Paid' ? const Color(0xFFECFDF3) : const Color(0xFFFFFAEB),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(p['status']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: p['status'] == 'Paid' ? const Color(0xFF027A48) : const Color(0xFFB4543E),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Text(p['date']!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, color: Color(0xFF475467)))),
                      ],
                    ),
                  )),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Add Milestone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
