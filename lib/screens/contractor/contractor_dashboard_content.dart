import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:converf/features/dashboard/providers/dashboard_providers.dart';
import 'package:converf/features/notifications/providers/notification_providers.dart';
import '../product_owner/widgets/dashboard/home/search_results_state.dart';
import '../product_owner/widgets/dashboard/home/search_empty_state.dart';
import 'package:converf/features/projects/providers/project_providers.dart';

class ContractorDashboardContent extends ConsumerStatefulWidget {
  const ContractorDashboardContent({super.key, this.onNavigateToProjects});

  final VoidCallback? onNavigateToProjects;

  @override
  ConsumerState<ContractorDashboardContent> createState() =>
      _ContractorDashboardContentState();
}

class _ContractorDashboardContentState
    extends ConsumerState<ContractorDashboardContent> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

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
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  : _ContractorHeader(onToggleSearch: _toggleSearch),
              ),

              // Body Area
              Expanded(
                child: _isSearching
                    ? _buildSearchBody()
                    : _ContractorDashboardBody(onNavigateToProjects: widget.onNavigateToProjects),
              ),
            ],
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
      return _ContractorDashboardBody(onNavigateToProjects: widget.onNavigateToProjects);
    }

    if (_searchQuery.toLowerCase().contains('lekki')) {
      return SearchResultsState(query: _searchQuery);
    } else {
      return SearchEmptyState(query: _searchQuery);
    }
  }
}

class _ContractorHeader extends ConsumerWidget {
  final VoidCallback onToggleSearch;
  const _ContractorHeader({required this.onToggleSearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider).asData?.value ?? 0;
    final unreadMessageCount = ref.watch(unreadMessageNotificationsCountProvider).asData?.value ?? 0;

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
                context.pushNamed('contractor-notifications');
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

class _ContractorDashboardBody extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToProjects;
  const _ContractorDashboardBody({this.onNavigateToProjects});

  @override
  ConsumerState<_ContractorDashboardBody> createState() => _ContractorDashboardBodyState();
}

class _ContractorDashboardBodyState extends ConsumerState<_ContractorDashboardBody> {
  @override
  void initState() {
    super.initState();
    // Removed aggressive 30-second auto-refresh timer which was causing
    // re-render loops on poor connections. Data loads once and can be
    // refreshed via the pull-to-refresh gesture.
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(assignedProjectsProvider(1));
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(unreadNotificationsCountProvider);
        ref.invalidate(unreadMessageNotificationsCountProvider);
      },
      color: const Color(0xFF2A8090),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ContractorMetricsGrid(onNavigateToProjects: widget.onNavigateToProjects),
            const SizedBox(height: 24),
            const _ContractorMarketStatsCard(),
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
            const _ContractorHighlights(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ContractorMetricsGrid extends ConsumerWidget {
  final VoidCallback? onNavigateToProjects;
  const _ContractorMetricsGrid({this.onNavigateToProjects});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => _buildLoadingMetrics(),
      error: (error, _) => _buildErrorState(
        'Failed to load metrics',
        error.toString(),
        () => ref.invalidate(dashboardStatsProvider),
      ),
      data: (statsResponse) {
        final stats = statsResponse.data;
        if (stats == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              children: [
                _buildMetricCard(
                  'Active Tasks',
                  stats.activeTasks.toString(),
                  'assets/images/Target.svg',
                  const Color(0xFFF0F9FB),
                  const Color(0xFF276572),
                  onTap: () => onNavigateToProjects?.call(),
                ),
                _buildMetricCard(
                  'Pending Invoices',
                  stats.pendingInvoices.toString(),
                  'assets/images/financial.svg',
                  const Color(0xFFFEF6FB),
                  const Color(0xFFD42620),
                ),
                _buildMetricCard(
                  'Upcoming Milestones',
                  stats.upcomingMilestones.toString(),
                  'assets/images/calendar-3.svg',
                  const Color(0xFFEFF8FF),
                  const Color(0xFF175CD3),
                ),
                _buildMetricCard(
                  'Total Earned',
                  stats.totalEarned ?? '₦0',
                  'assets/images/financial.svg',
                  const Color(0xFFECFDF3),
                  const Color(0xFF027A48),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Metrics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.25,
          children: List.generate(4, (index) => _buildLoadingCard()),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEAECF0)),
        ),
      ),
    );
  }

  Widget _buildErrorState(String title, String error, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB42318))),
          const SizedBox(height: 4),
          Text(
            error.contains('Network is unreachable') ? 'Network connection lost.' : error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFFB42318)),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: Color(0xFFB42318), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String iconPath,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAECF0)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101828),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractorMarketStatsCard extends ConsumerWidget {
  const _ContractorMarketStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (statsResponse) {
        final stats = statsResponse.data;
        String marketValueString = '₦0';
        if (stats != null) {
          final mv = stats.portfolioValue; 
          if (mv >= 1000000000) {
            marketValueString = '₦${(mv / 1000000000).toStringAsFixed(1)}B';
          } else if (mv >= 1000000) {
            marketValueString = '₦${(mv / 1000000).toStringAsFixed(1)}M';
          } else if (mv > 0) {
            marketValueString = '₦${mv.toStringAsFixed(0)}';
          }
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Market Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'This Month',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Total Marketplace Value',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                marketValueString,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Portfolio value across all active projects.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContractorHighlights extends ConsumerWidget {
  const _ContractorHighlights();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedProjectsAsync = ref.watch(assignedProjectsProvider(1));

    return assignedProjectsAsync.when(
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAECF0)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A8090)),
          ),
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

        final project = response.data.first;
        return _HighlightedContractorProjectCard(project: project);
      },
    );
  }
}

class _HighlightedContractorProjectCard extends StatelessWidget {
  final dynamic project;
  const _HighlightedContractorProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'contractor-project-details',
          pathParameters: {'projectId': project.id},
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/bg-1.png'),
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
                    const Color(0xFF8DC0DC).withValues(alpha: 0.9),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: project.status.color.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              project.status.label.toUpperCase(),
                              style: TextStyle(
                                color: project.status.color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: project.status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.black54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.formattedLocation,
                        style: TextStyle(
                          color: Colors.black87.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
