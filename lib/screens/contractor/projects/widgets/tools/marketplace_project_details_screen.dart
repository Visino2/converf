import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/providers/project_providers.dart';
import 'package:converf/features/marketplace/models/bid.dart';
import 'package:converf/features/marketplace/providers/marketplace_providers.dart';
import 'submit_proposal/submit_proposal_modal.dart';
import 'bid_detail_screen.dart';
import 'package:converf/features/projects/providers/project_document_providers.dart';
import 'package:converf/features/projects/providers/project_image_providers.dart';
import 'package:intl/intl.dart';
import 'package:converf/features/projects/providers/schedule_providers.dart';
import '../project_hub_modal.dart';

class MarketplaceProjectDetailsScreen extends ConsumerWidget {
  final String projectId;
  
  const MarketplaceProjectDetailsScreen({super.key, required this.projectId});


  void _showOverview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _OverviewSheet(projectId: projectId),
    );
  }

  void _showDocuments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DocumentsSheet(projectId: projectId),
    );
  }

  void _showSite(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SiteSheet(projectId: projectId),
    );
  }

  void _showClient(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ClientSheet(projectId: projectId),
    );
  }

  void _showSchedule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: projectId, initialTabIndex: 1),
    );
  }

  void _showDailyReports(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: projectId, initialTabIndex: 3),
    );
  }

  void _showFieldInspections(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectHubModal(projectId: projectId, initialTabIndex: 2),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Project Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.menu, color: Colors.black),
          ),
        ],
      ),
      body: ref.watch(projectDetailsProvider(projectId)).when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
        error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
        data: (projectData) {
          final project = projectData.data;

          if (project == null) {
            return const Scaffold(
              body: Center(child: Text('Project not found')),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      project.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),

                  Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/map.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF6B7280), BlendMode.srcIn),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        project.formattedLocation,
                        style:
                            const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    ),
                    const Spacer(),
                    _badge(project.status.label, const Color(0xFFFEF3C7),
                        project.status.color),
                    const SizedBox(width: 8),
                    if (project.constructionType.isNotEmpty)
                      _badge(project.constructionType.toUpperCase(), const Color(0xFFF0F2F5),
                          const Color(0xFF374151),
                          letterSpacing: 0.5),
                  ],
                ),
              ),

              
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/lekki-complex.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: const Color(0xFF309DAA)),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/camera.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Update Thumbnail',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bid Deadline',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                        const SizedBox(height: 4),
                        Text(project.formattedBiddingDeadline ?? 'No deadline',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827))),
                      ],
                    ),
                    const Spacer(),
                    ref.watch(myBidsProvider(1)).when(
                      loading: () => const CircularProgressIndicator(color: Color(0xFF276572)),
                      error: (_, _) => _buildSubmitButton(context), // Fallback to submit
                      data: (response) {
                        final existingBid = response.data.cast<Bid?>().firstWhere(
                          (b) => b?.projectId == projectId,
                          orElse: () => null,
                        );

                        if (existingBid != null) {
                          return _buildReviewButton(context, existingBid);
                        }
                        return _buildSubmitButton(context);
                      },
                    ),
                  ],
                ),
              ),

             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/infro.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF276572), BlendMode.srcIn),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Project Description',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  project.description.isNotEmpty ? project.description : 'No description provided.',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.6),
                ),
              ),
              const SizedBox(height: 20),

              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _detailRow(
                      icon: 'assets/images/check-circle.svg',
                      label: 'PROJECT TYPE',
                      value: project.constructionType.toUpperCase(),
                      color: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _detailItem(
                            'assets/images/bill-list.svg',
                            'ESTIMATED BUDGET',
                            project.formattedBudget,
                            const Color(0xFF276572),
                          ),
                        ),
                        Expanded(
                          child: _detailItem(
                            'assets/images/Calendar.svg',
                            'TIMELINE',
                            project.formattedDates,
                            const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _detailItem(
                            'assets/images/clock-circle.svg',
                            'STATUS',
                            project.status.label,
                            const Color(0xFF6B7280),
                          ),
                        ),
                        Expanded(
                          child: _detailItem(
                            'assets/images/map-1.svg',
                            'EXACT LOCATION',
                            project.formattedLocation,
                            const Color(0xFFF5B546),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                      icon: 'assets/images/shield-warning.svg',
                      label: 'VERIFICATION',
                      value: 'Required',
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: Color(0xFFF0F2F5))),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _tabButton(
                        context,
                        label: 'Overview',
                        iconPath: 'assets/images/home-2.svg',
                        iconColor: const Color(0xFF98A2B3),
                        onTap: () => _showOverview(context),
                      ),
                      const SizedBox(width: 16),
                      _tabButton(
                        context,
                        label: 'Schedule',
                        iconPath: 'assets/images/calendar-3.svg',
                        iconColor: const Color(0xFF98A2B3),
                        onTap: () => _showSchedule(context),
                      ),
                      const SizedBox(width: 16),
                      _tabButton(
                        context,
                        label: 'Documents',
                        iconPath: 'assets/images/document-1.svg',
                        iconColor: const Color(0xFF98A2B3),
                        onTap: () => _showDocuments(context),
                      ),
                      const SizedBox(width: 16),
                      _tabButton(
                        context,
                        label: 'Site',
                        iconPath: 'assets/images/site.svg',
                        iconColor: const Color(0xFF98A2B3),
                        onTap: () => _showSite(context),
                      ),
                      const SizedBox(width: 16),
                      _tabButton(
                        context,
                        label: 'Reports',
                        iconPath: 'assets/images/document-1.svg',
                        iconColor: const Color(0xFF98A2B3),
                        onTap: () => _showDailyReports(context),
                      ),
                      const SizedBox(width: 16),
                      _tabButton(
                        context,
                        label: 'Inspections',
                        iconPath: 'assets/images/Target.svg',
                        iconColor: const Color(0xFF98A2B3),
                        onTap: () => _showFieldInspections(context),
                      ),
                      const SizedBox(width: 16),
                      _tabButton(
                        context,
                        label: 'Client',
                        iconPath: 'assets/images/more.svg',
                        iconColor: const Color(0xFF98A2B3),
                        onTap: () => _showClient(context),
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
      }),
    );
  }



  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SubmitProposalModal(projectId: projectId),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF276572),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: const Text(
        'Submit Proposal',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context, Bid bid) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BidDetailScreen(bid: bid)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF276572)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Text(
            'Review Proposal',
            style: TextStyle(color: Color(0xFF276572), fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: bid.status == 'accepted' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            bid.status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: bid.status == 'accepted' ? const Color(0xFF166534) : const Color(0xFF92400E),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _badge(String text, Color bg, Color fg,
      {double letterSpacing = 0}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: letterSpacing),
      ),
    );
  }

  static Widget _tabButton(
    BuildContext context, {
    required String label,
    required String iconPath,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 22,
            height: 22,
            colorFilter:
                ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  static Widget _detailRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827))),
          ],
        ),
      ],
    );
  }

  static Widget _detailItem(
      String icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }
}



class _OverviewSheet extends ConsumerWidget {
  final String projectId;
  const _OverviewSheet({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(projectScheduleProvider(projectId));
    
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/home-2.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF276572), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Overview',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Phases',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827))),
          const SizedBox(height: 20),
          scheduleAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Schedule not available for this project',
                  style: TextStyle(color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                ),
              ),
            ),
            data: (schedule) {
              if (schedule.phases.isEmpty) {
                return const Center(child: Text('No phases found'));
              }
              return Column(
                children: [
                  ...schedule.phases.asMap().entries.map((entry) {
                    final index = entry.key;
                    final phase = entry.value;
                    return _phaseItem(phase.name, index == schedule.phases.length - 1);
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _phaseItem(String label, bool isLast) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFBFDBFE), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF276572), width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Color(0xFF276572),
                            shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 36, color: const Color(0xFFE5E7EB)),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }
}



class _DocumentsSheet extends ConsumerWidget {
  final String projectId;
  const _DocumentsSheet({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(projectDocumentsProvider(projectId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/document-1.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF276572), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Documents',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Project Documents',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 16),
          docsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading documents: $err')),
            data: (docs) {
              if (docs.isEmpty) {
                 return const Center(child: Padding(
                   padding: EdgeInsets.symmetric(vertical: 40),
                   child: Text('No documents uploaded for this project.'),
                 ));
              }
              return Column(
                children: docs.map((doc) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insert_drive_file, color: Color(0xFF276572)),
                  title: Text(doc.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('${doc.type.toUpperCase()} • ${DateFormat('MMM d, y').format(doc.createdAt)}', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.download, size: 20),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}



class _SiteSheet extends ConsumerWidget {
  final String projectId;
  const _SiteSheet({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    final imagesAsync = ref.watch(projectImagesProvider(projectId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/site.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF276572), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Site Details',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          projectAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (response) {
              final project = response.data;
              if (project == null) return const Center(child: Text('Project not found'));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(project.formattedLocation, style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
                  const SizedBox(height: 24),
                  imagesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => const SizedBox.shrink(),
                    data: (images) {
                      if (images.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Site Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 12),
                              itemBuilder: (_, i) => ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  images[i].fileUrl,
                                  width: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(width: 160, color: const Color(0xFFF3F4F6), child: const Icon(Icons.image)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


class _ClientSheet extends ConsumerWidget {
  final String projectId;
  const _ClientSheet({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.50,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/more.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF276572), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Client',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          projectAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (response) {
              final project = response.data;
              if (project == null || project.owner == null) return const Center(child: Text('Client info not available'));
              final owner = project.owner!;
              return Column(
                children: [
                   Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFF276572),
                        child: Text(owner.displayName.isNotEmpty ? owner.displayName[0].toUpperCase() : 'C',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                owner.displayName,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827)),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified,
                                  color: Color(0xFF2A8090), size: 18),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.star,
                                  color: Color(0xFFF59E0B), size: 14),
                              SizedBox(width: 4),
                              Text('4.9',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFF0F2F5)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statCell('PROJECTS', '8'),
                      _statCell('HIRE RATE', '90%'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statCell('EMAIL', owner.email),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.4),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }
}
