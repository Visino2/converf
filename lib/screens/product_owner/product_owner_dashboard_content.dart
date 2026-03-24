import 'package:flutter/material.dart';
import 'widgets/dashboard/home/search_empty_state.dart';
import 'widgets/dashboard/home/search_results_state.dart';
import 'widgets/dashboard/new_project_modal.dart';
import 'widgets/dashboard/messages/project_inbox_screen.dart';
import 'widgets/dashboard/projects/project_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/providers/project_providers.dart';
import 'package:converf/features/projects/models/project.dart';
import 'package:converf/features/dashboard/providers/dashboard_providers.dart';

class ProductOwnerDashboardContent extends ConsumerStatefulWidget {
  const ProductOwnerDashboardContent({super.key});

  @override
  ConsumerState<ProductOwnerDashboardContent> createState() => _ProductOwnerDashboardContentState();
}

class _ProductOwnerDashboardContentState extends ConsumerState<ProductOwnerDashboardContent> {
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
                child: _isSearching ? _buildSearchBar() : _buildNormalHeader(),
              ),

              // Body Area
              Expanded(
                child: _isSearching ? _buildSearchBody() : _buildDashboardBody(),
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
                      shadowColor: const Color(0xFF2A8090).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
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

  Widget _buildNormalHeader() {
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
            SvgPicture.asset('assets/images/Bell.svg', width: 24, height: 24),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectInboxScreen(),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset('assets/images/message.svg', width: 24, height: 24),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD42620), // Standard red dot
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _toggleSearch,
              child: SvgPicture.asset('assets/images/search.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ],
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
                  child: SvgPicture.asset('assets/images/search.svg',
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
      // Show full dashboard when search is open but empty
      return _buildDashboardBody();
    }

    if (_searchQuery.toLowerCase().contains('lekki')) {
      return SearchResultsState(query: _searchQuery);
    } else {
      return SearchEmptyState(query: _searchQuery);
    }
  }

  Widget _buildDashboardBody() {
    final projectsAsync = ref.watch(projectsListProvider(1));
    final statsAsync = ref.watch(dashboardStatsProvider);

    // Handle projects loading/error first as it's the primary data
    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2A8090))),
      error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      data: (projectsResponse) {
        final highlightedProject = projectsResponse.data.isNotEmpty ? projectsResponse.data.first : null;

        // Then handle stats
        return statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2A8090))),
          error: (error, _) => Center(child: Text('Error loading stats: $error', style: const TextStyle(color: Colors.red))),
          data: (statsResponse) {
            final stats = statsResponse.data;
            final totalProjects = stats?.activeProjects ?? projectsResponse.meta?.total ?? projectsResponse.data.length;
            
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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Analysis Card
                  _buildAiAnalysisCard(),
                  const SizedBox(height: 24),

                  // Grid Stats
                  _buildStatsGrid(totalProjects, stats, portfolioString),
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

                  if (highlightedProject != null)
                    _buildHighlightedProjectCard(highlightedProject)
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No active projects to highlight.', style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  const SizedBox(height: 100), 
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiAnalysisCard() {
    return Container(
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
                child: SvgPicture.asset('assets/images/metallic-paint.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Analysis Complete',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                width: 70,
                height: 24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F973D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '2h ago',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "I've analyzed all your projects: 1 critical area needs attention, 2 optimization opportunities found. VI Towers trending toward major delays without intervention.",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int totalProjects, dynamic stats, String portfolioString) {
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
        ),
        _buildStatCard(
          'Avg Quality Score',
          stats != null ? '${stats.avgQualityScore.toStringAsFixed(1)}%' : '88.3%',
          'assets/images/filecheck.svg',
          const Color(0xFFE8F5E9), 
          const Color(0xFF0F973D),
        ),
        _buildStatCard(
          'Ball-in-courts',
          stats?.ballInCourts.toString() ?? '2',
          'assets/images/shield-warning.svg',
          const Color(0xFFFBEAE9), 
          const Color(0xFFEB9B98), 
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
  }

  Widget _buildHighlightedProjectCard(Project highlightedProject) {
    return GestureDetector(
      onTap: () {
        if (highlightedProject.status == ProjectStatus.draft || highlightedProject.currentStep < 5) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NewProjectModal(initialProject: highlightedProject),
          );
        } else {
          // Normal navigation to project details
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailsScreen(projectId: highlightedProject.id)));
        }
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
                          highlightedProject.title,
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
                          color: highlightedProject.status.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              highlightedProject.status.label.toUpperCase(),
                              style: TextStyle(
                                color: highlightedProject.status.color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: highlightedProject.status.color,
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
                        highlightedProject.formattedLocation,
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

  Widget _buildStatCard(
    String title,
    String value,
    String imagePath,
    Color innerColor,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Dotted Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: _cachedDottedGridPainter,
            ),
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
                          borderColor.withValues(alpha: 1.0).computeLuminance() > 0.5 
                            ? borderColor.withValues(alpha: 1.0).withRed(10).withGreen(120).withBlue(130) // Fallback for very light colors
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
