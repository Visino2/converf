import 'dart:math';

import 'package:flutter/material.dart';
import 'widgets/dashboard/home/search_empty_state.dart';
import 'widgets/dashboard/home/search_results_state.dart';
import 'widgets/dashboard/new_project_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/providers/project_providers.dart';
import 'package:converf/features/projects/models/project.dart';
import 'package:converf/features/projects/providers/project_advisory_providers.dart';
import 'package:converf/features/dashboard/providers/dashboard_providers.dart';
import 'package:converf/features/notifications/providers/notification_providers.dart';
import 'package:converf/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:converf/features/billing/providers/billing_providers.dart';
import '../widgets/modals/upgrade_plan_modal.dart';
import 'widgets/dashboard/projects/update_assignment_dialog.dart';

class ProductOwnerDashboardContent extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToProjects;
  const ProductOwnerDashboardContent({super.key, this.onNavigateToProjects});

  @override
  ConsumerState<ProductOwnerDashboardContent> createState() =>
      _ProductOwnerDashboardContentState();
}

class _ProductOwnerDashboardContentState
    extends ConsumerState<ProductOwnerDashboardContent>
    with WidgetsBindingObserver {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDash());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDash();
    }
  }

  void _refreshDash() {
    ref.invalidate(projectsListProvider(1));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(dashboardAdvisoryProvider);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      } else {
        _searchFocus.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep subscription data warm in memory
    ref.watch(billingSubscriptionProvider);

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Header Area
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: _isSearching
                    ? _buildSearchBar()
                    : _DashboardHeader(onToggleSearch: _toggleSearch),
              ),

              // Body Area
              Expanded(
                child: _isSearching
                    ? _buildSearchBody()
                    : _DashboardBody(
                        onNavigateToProjects: widget.onNavigateToProjects,
                      ),
              ),
            ],
          ),
          if (!_isSearching)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A8090),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      elevation: 8,
                      shadowColor: const Color(
                        0xFF2A8090,
                      ).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      // More robust check for active projects.
                      final statsState = ref.read(dashboardStatsProvider);
                      final projectsState = ref.read(projectsListProvider(1));

                      int activeProjects = 0;

                      // 1. Check statistics
                      if (statsState.hasValue) {
                        activeProjects = max(
                          activeProjects,
                          statsState.value?.data?.activeProjects ?? 0,
                        );
                      }

                      // 2. Check project list metadata (more direct)
                      if (projectsState.hasValue) {
                        activeProjects = max(
                          activeProjects,
                          projectsState.value?.meta?.total ?? 0,
                        );
                      }

                      // 3. Check subscription limits
                      final subState = ref.read(billingSubscriptionProvider);
                      final authState = ref.read(authProvider);

                      int maxProjects = 1; // Default for free plan

                      bool isPremiumPlan = false;
                      final userPlan =
                          authState.value?.user['plan']
                              ?.toString()
                              .toLowerCase() ??
                          '';
                      if (userPlan.contains('builder') ||
                          userPlan.contains('starter') ||
                          userPlan.contains('professional')) {
                        isPremiumPlan = true;
                      }

                      if (subState.hasValue &&
                          subState.value?.limits?.maxProjects != null) {
                        maxProjects = subState.value!.limits!.maxProjects!;
                      } else if (isPremiumPlan) {
                        // Safe fallback if billing data is still loading but we know they are premium
                        maxProjects = 10;
                      }

                      debugPrint(
                        'CHECK: active=$activeProjects, max=$maxProjects, plan=$userPlan, isPremium=$isPremiumPlan',
                      );

                      if (activeProjects >= maxProjects) {
                        debugPrint('LIMIT REACHED: showing upgrade modal');
                        await showUpgradePlanModal(context);
                        return;
                      }

                      debugPrint('PROCEED: opening new project modal');

                      if (!context.mounted) return;
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const NewProjectModal(),
                      );
                    },
                    icon: SvgPicture.asset(
                      'assets/images/button-icon.svg',
                      width: 24,
                      height: 24,
                    ),
                    label: const Text(
                      'New Project',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black54,
            ),
            onPressed: _toggleSearch,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: SvgPicture.asset(
                    'assets/images/search.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      _searchQuery.toLowerCase().contains('lekki')
                          ? Colors.black
                          : const Color(0xFF344054),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.black54),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBody() {
    if (_searchQuery.isEmpty) {
      return _DashboardBody(onNavigateToProjects: widget.onNavigateToProjects);
    }

    if (_searchQuery.toLowerCase().contains('lekki')) {
      return SearchResultsState(query: _searchQuery);
    } else {
      return SearchEmptyState(query: _searchQuery);
    }
  }
}

class _DashboardHeader extends ConsumerWidget {
  final VoidCallback onToggleSearch;
  const _DashboardHeader({required this.onToggleSearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final unreadMessageCount = ref.watch(
      unreadMessageNotificationsCountProvider,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                context.pushNamed('notifications');
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    'assets/images/Bell.svg',
                    width: 24,
                    height: 24,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD42620),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                context.pushNamed('messages');
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    'assets/images/message.svg',
                    width: 24,
                    height: 24,
                  ),
                  if (unreadMessageCount > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD42620),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadMessageCount > 99
                              ? '99+'
                              : unreadMessageCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onToggleSearch,
              child: SvgPicture.asset(
                'assets/images/search.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final VoidCallback? onNavigateToProjects;
  const _DashboardBody({this.onNavigateToProjects});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(projectsListProvider(1));
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(dashboardAdvisoryProvider);
      },
      color: const Color(0xFF2A8090),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DashboardAdvisoryCard(),
            const SizedBox(height: 24),
            _DashboardStatsGrid(onNavigateToProjects: onNavigateToProjects),
            const SizedBox(height: 32),
            const Text(
              'Project Highlights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const _DashboardHighlights(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _DashboardAdvisoryCard extends ConsumerWidget {
  const _DashboardAdvisoryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advisoryState = ref.watch(dashboardAdvisoryProvider);

    return advisoryState.when(
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFEAECF0)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF276572)),
        ),
      ),
      error: (err, _) => const SizedBox.shrink(),
      data: (advisory) {
        if (advisory == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE0D3), Color(0xFFFF9A6C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFED0AA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/metallic-paint.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Analysis Complete',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F973D),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Health Score: ${advisory.healthScore}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                advisory.healthMessage,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardStatsGrid extends ConsumerWidget {
  final VoidCallback? onNavigateToProjects;
  const _DashboardStatsGrid({this.onNavigateToProjects});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final projectsAsync = ref.watch(projectsListProvider(1));

    return projectsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2A8090)),
      ),
      error: (err, _) => const SizedBox.shrink(),
      data: (projectsResponse) {
        return statsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2A8090)),
          ),
          error: (error, _) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (statsResponse) {
            final stats = statsResponse.data;
            final projects = projectsResponse.data;
            final activeFromList = projects
                .where((p) => p.status == ProjectStatus.active)
                .length;
            final totalProjects = max(
              stats?.activeProjects ?? 0,
              max(
                activeFromList,
                max(projectsResponse.meta?.total ?? 0, projects.length),
              ),
            );

            String portfolioString = '₦0';
            if (stats != null) {
              final pv = stats.portfolioValue;
              if (pv >= 1000000000) {
                portfolioString = '₦${(pv / 1000000000).toStringAsFixed(1)}B';
              } else if (pv >= 1000000) {
                portfolioString = '₦${(pv / 1000000).toStringAsFixed(1)}M';
              } else if (pv > 0) {
                portfolioString = '₦${pv.toStringAsFixed(0)}';
              }
            }

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  'Active Projects',
                  totalProjects.toString(),
                  'assets/images/projects.svg',
                  const Color(0xFFE4F8F9),
                  const Color(0xFFB7E7EA),
                  onTap: onNavigateToProjects,
                ),
                _buildStatCard(
                  'Avg Quality Score',
                  stats != null
                      ? '${stats.avgQualityScore.toStringAsFixed(1)}%'
                      : '88.3%',
                  'assets/images/filecheck.svg',
                  const Color(0xFFE8F5E9),
                  const Color(0xFF0F973D),
                ),
                _buildStatCard(
                  'Ball-in-courts',
                  stats?.ballInCourts.toString() ?? '2',
                  'assets/images/basketball.svg',
                  const Color(0xFFFBEAE9),
                  const Color(0xFFEB9B98),
                  onTap: () {
                    final targetProjectIndex = projects.indexWhere(
                      (p) =>
                          p.status == ProjectStatus.atRisk ||
                          p.status == ProjectStatus.delayed,
                    );

                    if (targetProjectIndex != -1) {
                      context.pushNamed(
                        'project-details',
                        pathParameters: {
                          'projectId': projects[targetProjectIndex].id,
                        },
                      );
                    } else if (onNavigateToProjects != null) {
                      onNavigateToProjects!();
                    }
                  },
                ),
                _buildStatCard(
                  'Portfolio Value',
                  portfolioString,
                  'assets/images/Case.svg',
                  const Color(0xFFE4F8F9),
                  const Color(0xFFB7E7EA),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String imagePath,
    Color innerColor,
    Color borderColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F2F5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _cachedDottedGridPainter),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: innerColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: borderColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: SvgPicture.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            borderColor.computeLuminance() > 0.5
                                ? const Color(0xFF276572)
                                : borderColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHighlights extends ConsumerWidget {
  const _DashboardHighlights();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider(1));

    return projectsAsync.when(
      loading: () => const SizedBox(
        height: 380,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF2A8090)),
        ),
      ),
      error: (err, _) => const SizedBox.shrink(),
      data: (response) {
        if (response.data.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No active projects to highlight.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        return SizedBox(
          height: 380,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: response.data.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width - 48,
                child: _HighlightedProjectCard(project: response.data[index]),
              );
            },
          ),
        );
      },
    );
  }
}

class _HighlightedProjectCard extends StatelessWidget {
  final Project project;
  const _HighlightedProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (project.status == ProjectStatus.draft || project.currentStep < 5) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NewProjectModal(initialProject: project),
          );
        } else {
          context.pushNamed(
            'project-details',
            pathParameters: {'projectId': project.id},
          );
        }
      },
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image:
                (project.coverImage != null && project.coverImage!.isNotEmpty)
                ? NetworkImage(project.coverImage!) as ImageProvider
                : const AssetImage('assets/images/bg-1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF111827).withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: project.assignmentMethod == 'decide_later'
                              ? const Color(0xFFFFF3E0) // Orange background
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          project.assignmentMethod == 'decide_later'
                              ? '⏸️ AWAITING ASSIGNMENT'
                              : project.status.label.toUpperCase(),
                          style: TextStyle(
                            color: project.assignmentMethod == 'decide_later'
                                ? const Color(0xFFF57C00) // Orange text
                                : project.status.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    project.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.formattedLocation,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (project.status != ProjectStatus.draft)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Budget',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                project.formattedBudget,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 24, color: Colors.white24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time Left',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                project.daysRemaining,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (project.assignmentMethod == 'decide_later') ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => UpdateAssignmentDialog(
                          projectId: project.id,
                          currentAssignmentMethod: project.assignmentMethod,
                          currentContractorId: project.contractorId,
                          currentBiddingDeadline: project.biddingDeadline,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF276572),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Update Assignment',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _cachedDottedGridPainter = _DottedGridPainter();

class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    const spacing = 12.0;
    const dotSize = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
