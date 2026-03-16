import 'package:flutter/material.dart';
import '../product_owner/widgets/dashboard/messages/project_inbox_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/marketplace/providers/marketplace_providers.dart';
import 'package:converf/features/dashboard/providers/dashboard_providers.dart';
import 'package:converf/core/utils/project_utils.dart';
import '../product_owner/widgets/dashboard/home/search_results_state.dart';
import '../product_owner/widgets/dashboard/home/search_empty_state.dart';

class ContractorDashboardContent extends ConsumerStatefulWidget {
  const ContractorDashboardContent({super.key});

  @override
  ConsumerState<ContractorDashboardContent> createState() => _ContractorDashboardContentState();
}

class _ContractorDashboardContentState extends ConsumerState<ContractorDashboardContent> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
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
    final marketplaceAsync = ref.watch(marketplaceProjectsProvider(1));
    final statsAsync = ref.watch(dashboardStatsProvider);

    return marketplaceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2A8090))),
      error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      data: (marketplaceResponse) {
        final highlightedProject = marketplaceResponse.data.isNotEmpty ? marketplaceResponse.data.first : null;

        return statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2A8090))),
          error: (error, _) => Center(child: Text('Error loading stats: $error', style: const TextStyle(color: Colors.red))),
          data: (statsResponse) {
            final stats = statsResponse.data;
            
            String marketValueString = '₦0';
            if (stats != null) {
              final mv = stats.portfolioValue; // Using portfolioValue as marketValue
              if (mv >= 1000000000) {
                marketValueString = '₦${(mv / 1000000000).toStringAsFixed(1)}B';
              } else if (mv >= 1000000) {
                marketValueString = '₦${(mv / 1000000).toStringAsFixed(1)}M';
              } else if (mv > 0) {
                marketValueString = '₦${mv.toStringAsFixed(0)}';
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Update Progress Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildUpdateProgressCard(
                          'Update Project\nProgress',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUpdateProgressCard(
                          'Update Project\nFinancials',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Market Statistics Card
                  _buildMarketStatsCard(marketValueString),
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

  Widget _buildMarketStatsCard(String value) {
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
                  color: Colors.white.withOpacity(0.1),
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
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '+12.5% ',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'from last month',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedProjectCard(dynamic highlightedProject) {
    return Container(
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
                  const Color(0xFF8DC0DC).withOpacity(0.9),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
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
                        color: highlightedProject.status.color.withOpacity(0.15),
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
                        color: Colors.black87.withOpacity(0.7),
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
    );
  }

  Widget _buildUpdateProgressCard(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F9FB),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset('assets/images/camera.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF276572),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Update Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
              painter: _DottedGridPainter(),
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
                          color: borderColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: SvgPicture.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          borderColor.withOpacity(1.0).computeLuminance() > 0.5 
                            ? borderColor.withOpacity(1.0).withRed(10).withGreen(120).withBlue(130) // Fallback for very light colors
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

  Widget _buildFilterChips() {
    final filters = ['All', 'Overdue', 'This Week'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF276572) : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9).withOpacity(0.5)
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
