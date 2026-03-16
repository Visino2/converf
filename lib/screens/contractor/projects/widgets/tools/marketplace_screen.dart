import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/models/project.dart';
import 'package:converf/features/marketplace/providers/marketplace_providers.dart';
import 'package:converf/core/utils/project_utils.dart';
import 'marketplace_project_details_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  bool _browseSelected = true;
  final _searchController = TextEditingController();
  final List<String> _activeFilters = ['Lagos, Ng', 'Abuja, NG', '+2'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    // Basic search setup complete. Handled below in provider logic.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
          'Market Place',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top row: Browse / My Bids / Funnel ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _buildToggleBtn('Browse Projects', _browseSelected, () {
                    setState(() => _browseSelected = true);
                  }),
                  const SizedBox(width: 12),
                  _buildToggleBtn('My Bids', !_browseSelected, () {
                    setState(() => _browseSelected = false);
                  }),
                  const Spacer(),
                  // Funnel icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/funnel.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF4B5563), BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

           
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: Column(
                  children: [
                    // Filter dropdowns
                    Row(
                      children: [
                        _buildDropdown('Project type'),
                        const SizedBox(width: 8),
                        _buildDropdown('Location'),
                        const SizedBox(width: 8),
                        _buildDropdown('Budget'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            'assets/images/search.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                                Color(0xFF9CA3AF), BlendMode.srcIn),
                          ),
                        ),
                        hintText: 'Search here...',
                        hintStyle: const TextStyle(
                            fontSize: 14, color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: const Color(0xFFF0F2F5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFF0F2F5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF276572), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Active filter chips
                    Row(
                      children: [
                        ..._activeFilters.map((f) => _buildFilterChip(f)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _activeFilters.clear()),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 15, color: Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            
            Expanded(
              child: _browseSelected
                  ? ref.watch(marketplaceProjectsProvider(1)).when(
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
                      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                      data: (response) {
                        final q = _searchController.text.toLowerCase();
                        final projects = response.data.where((p) =>
                            p.title.toLowerCase().contains(q) ||
                            p.location.toLowerCase().contains(q)).toList();

                        if (projects.isEmpty) {
                          return const Center(child: Text('No marketplace projects found', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: projects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, i) => _buildProjectCard(context, projects[i]),
                        );
                      },
                    )
                  : ref.watch(myBidsProvider(1)).when(
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
                      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                      data: (response) {
                        final bids = response.data;
                        if (bids.isEmpty) {
                          return const Center(child: Text('You have not placed any bids yet', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: bids.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, i) {
                            final project = bids[i].project;
                            if (project == null) return const SizedBox.shrink();
                            return _buildProjectCard(context, project);
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

 

  Widget _buildToggleBtn(
      String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF276572)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280))),
            const Icon(Icons.keyboard_arrow_down,
                size: 15, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFB7E7EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F5F6B),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarketplaceProjectDetailsScreen(projectId: p.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Expanded(
                child: Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified,
                  color: Color(0xFF4ADE80), size: 18),
            ],
          ),
          const SizedBox(height: 4),
     
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/map.svg',
                width: 13,
                height: 13,
                colorFilter: const ColorFilter.mode(
                    Color(0xFF6B7280), BlendMode.srcIn),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  p.formattedLocation,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                'assets/images/lekki-complex.png', // Temporary placeholder
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF309DAA)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F2F5)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                    'assets/images/bill-list.svg', p.formattedBudget),
                _buildStatChip(
                    'assets/images/Calendar.svg', p.formattedDates.split(' - ').first),
                _buildStatChip(
                    'assets/images/clock-circle.svg', p.status.label),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String iconPath, String label) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 14,
          height: 14,
          colorFilter:
              const ColorFilter.mode(Color(0xFF6B7280), BlendMode.srcIn),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
