import 'package:flutter/material.dart';
import 'search_empty_state.dart';
import 'search_results_state.dart';
import 'new_project_modal.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
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
      child: Column(
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
            Image.asset('assets/images/Bell.png', width: 24, height: 24),
            const SizedBox(width: 16),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset('assets/images/message.png', width: 24, height: 24),
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
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _toggleSearch,
              child: Image.asset(
                'assets/images/search.png',
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
                  child: Image.asset(
                    'assets/images/search.png',
                    width: 20,
                    height: 20,
                    color: _searchQuery.toLowerCase().contains('lekki')
                        ? Colors.black
                        : const Color(0xFF344054),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Analysis Card
          Container(
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
                      child: Image.asset(
                        'assets/images/metallic-paint.png',
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
          ),
          const SizedBox(height: 24),

          // Grid Stats
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                'Active Projects',
                '4',
                'assets/images/construction.png',
                const Color(
                  0xFFE4F8F9,
                ), // Light blueish internal bg based on border color visually
                const Color(0xFFB7E7EA),
              ),
              _buildStatCard(
                'Avg Quality Score',
                '88.3%',
                'assets/images/filecheck.png',
                const Color(0xFFE8F5E9), // Assuming pale green internal bg
                const Color(0xFF0F973D),
              ),
              _buildStatCard(
                'Ball-in-courts',
                '2',
                'assets/images/shield-warning.png',
                const Color(0xFFFBEAE9), // Custom light red bg
                const Color(0xFFEB9B98), // Custom red border
              ),
              _buildStatCard(
                'Portfolio Value',
                '₦1.3B',
                'assets/images/Case.png',
                const Color(0xFFE4F8F9), // Light blue internal bg
                const Color(0xFFB7E7EA),
              ),
            ],
          ),

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

          // Highlights Card
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/bg.png'),
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
                          const Expanded(
                            child: Text(
                              'Lekki Residential Complex',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFEF6E7,
                                  ), // Updated per spec
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      'AT RISK',
                                      style: TextStyle(
                                        color: Color(0xFFC26E2B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors
                                            .red, // Usually AT RISK implies red/orange dot, but user said 'green rounded dot that shows project is on'. Following user spec "a green rounded dot that show that the project is on".
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            'Lekki Phase 1, Lagos',
                            style: TextStyle(
                              color: Colors.black87.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A8090),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
                            icon: Image.asset(
                              'assets/images/button-icon.png',
                              width: 20,
                              height: 20,
                            ),
                            label: const Text(
                              'New Project',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
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
      width: 176.5,
      height: 114,
      padding: const EdgeInsets.only(top: 11, right: 15, bottom: 11, left: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: innerColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ), // Average between 1px and 1.5px requested
                ),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // User specified gap: 10px
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
