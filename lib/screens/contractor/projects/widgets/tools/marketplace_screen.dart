import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/models/project.dart';
import 'package:converf/features/marketplace/models/bid.dart';
import 'package:converf/features/marketplace/models/marketplace_filters.dart';
import 'package:converf/features/marketplace/providers/marketplace_providers.dart';
import 'marketplace_project_details_screen.dart';
import 'marketplace_filter_sheet.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  final bool initialShowMyBids;
  final bool showBackButton;

  const MarketplaceScreen({
    super.key,
    this.initialShowMyBids = false,
    this.showBackButton = true,
  });

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  late bool _browseSelected;
  final _searchController = TextEditingController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _browseSelected = !widget.initialShowMyBids;
    _searchController.addListener(_onSearch);
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint('[Marketplace] Auto-refreshing projects and bids...');
        ref.invalidate(marketplaceProjectsProvider);
        ref.invalidate(myBidsProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(marketplaceFiltersProvider.notifier).update(
      (state) => state.copyWith(searchQuery: _searchController.text),
    );
  }


  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(marketplaceFiltersProvider);
    final args = (page: 1, filters: filters);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const MarketplaceFilterSheet(),
                      );
                    },
                    child: Container(
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
                            Color(0xFF4B5563),
                            BlendMode.srcIn,
                          ),
                        ),
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
                              Color(0xFF9CA3AF),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        hintText: 'Search projects...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFF0F2F5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFF0F2F5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF276572),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Dynamic Active filter chips
                    if (!filters.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    if (filters.location != null && filters.location!.isNotEmpty)
                                      _buildFilterChip(
                                        filters.location!,
                                        () => ref.read(marketplaceFiltersProvider.notifier).update(
                                          (s) => s.copyWith(location: ''),
                                        ),
                                      ),
                                    if (filters.constructionType != null && filters.constructionType != 'all')
                                      _buildFilterChip(
                                        filters.constructionType!,
                                        () => ref.read(marketplaceFiltersProvider.notifier).update(
                                          (s) => s.copyWith(constructionType: 'all'),
                                        ),
                                      ),
                                    if (filters.minBudget != null)
                                      _buildFilterChip(
                                        '₦${(filters.minBudget! / 1000000).toStringAsFixed(1)}M+',
                                        () => ref.read(marketplaceFiltersProvider.notifier).update(
                                          (s) => s.copyWith(minBudget: null, maxBudget: null),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => ref.read(marketplaceFiltersProvider.notifier).state = MarketplaceFilters(),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 15,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _browseSelected
                  ? ref
                        .watch(marketplaceProjectsProvider(args))
                        .when(
                          loading: () =>
                              ref.watch(marketplaceProjectsProvider(args)).hasValue
                              ? _buildBrowseBody(
                                  ref
                                      .watch(marketplaceProjectsProvider(args))
                                      .value!,
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF276572),
                                  ),
                                ),
                          error: (err, _) => Center(
                            child: Text(
                              'Error: $err',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          data: (response) => _buildBrowseBody(response),
                        )
                  : ref
                        .watch(myBidsProvider(1))
                        .when(
                          loading: () => ref.watch(myBidsProvider(1)).hasValue
                              ? _buildMyBidsBody(
                                  ref.watch(myBidsProvider(1)).value!,
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF276572),
                                  ),
                                ),
                          error: (err, _) => Center(
                            child: Text(
                              'Error: $err',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          data: (response) => _buildMyBidsBody(response),
                        ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseBody(dynamic response) {
    final projects = response.data;

    if (projects.isEmpty) {
      return const Center(
        child: Text(
          'No projects match your filters',
          style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: projects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) => _buildProjectCard(context, projects[i]),
    );
  }

  Widget _buildMyBidsBody(dynamic response) {
    final bids = response.data;
    if (bids.isEmpty) {
      return const Center(
        child: Text(
          'You have not placed any bids yet',
          style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bids.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final project = bids[i].project;
        if (project == null) return const SizedBox.shrink();
        return _buildProjectCard(context, project, bid: bids[i]);
      },
    );
  }


  Widget _buildToggleBtn(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF276572) : const Color(0xFFF3F4F6),
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

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFB7E7EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F5F6B),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF0F5F6B)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project p, {Bid? bid}) {
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
              if (bid != null)
                _buildBidStatusBadge(bid.status)
              else
                const Icon(Icons.verified, color: Color(0xFF4ADE80), size: 18),
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
                  Color(0xFF6B7280),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  p.formattedLocation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
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
              child: p.coverImage != null && p.coverImage!.isNotEmpty
                  ? Image.network(
                      p.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: const Color(0xFF309DAA)),
                    )
                  : Image.asset(
                      'assets/images/lekki-complex.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: const Color(0xFF309DAA)),
                    ),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F2F5)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                  'assets/images/bill-list.svg',
                  p.formattedBudget,
                ),
                _buildStatChip(
                  'assets/images/Calendar.svg',
                  p.formattedDates.split(' - ').first,
                ),
                _buildStatChip(
                  'assets/images/clock-circle.svg',
                  p.status.label,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'accepted':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        break;
      case 'shortlisted':
        bg = const Color(0xFFF0FBFB);
        fg = const Color(0xFF309DAA);
        break;
      case 'rejected':
      case 'declined':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
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
          colorFilter: const ColorFilter.mode(
            Color(0xFF6B7280),
            BlendMode.srcIn,
          ),
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
