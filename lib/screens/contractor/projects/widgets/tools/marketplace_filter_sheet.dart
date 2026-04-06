import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/marketplace/models/marketplace_filters.dart';
import '../../../../../features/marketplace/providers/marketplace_providers.dart';

class MarketplaceFilterSheet extends ConsumerStatefulWidget {
  const MarketplaceFilterSheet({super.key});

  @override
  ConsumerState<MarketplaceFilterSheet> createState() => _MarketplaceFilterSheetState();
}

class _MarketplaceFilterSheetState extends ConsumerState<MarketplaceFilterSheet> {
  late TextEditingController _locationController;
  String? _selectedType;
  RangeValues _budgetRange = const RangeValues(0, 100000000);
  String _orderBy = 'recent';

  final List<String> _projectTypes = [
    'all',
    'Residential',
    'Commercial',
    'Industrial',
    'Infrastructure',
    'Renovation',
  ];

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(marketplaceFiltersProvider);
    _locationController = TextEditingController(text: currentFilters.location);
    _selectedType = currentFilters.constructionType ?? 'all';
    _orderBy = currentFilters.orderBy ?? 'recent';
    if (currentFilters.minBudget != null || currentFilters.maxBudget != null) {
      _budgetRange = RangeValues(
        currentFilters.minBudget ?? 0,
        currentFilters.maxBudget ?? 100000000,
      );
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E7EC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(marketplaceFiltersProvider.notifier).state = MarketplaceFilters();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Reset All',
                    style: TextStyle(color: Color(0xFF667085)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'e.g. Lagos, Nigeria',
                hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF667085)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Project Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _projectTypes.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type == 'all' ? 'All Types' : type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedType = type);
                  },
                  selectedColor: const Color(0xFFB7E7EA),
                  backgroundColor: const Color(0xFFF9FAFB),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF344054) : const Color(0xFF667085),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF309DAA) : const Color(0xFFD0D5DD),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Budget Range (₦)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₦${(_budgetRange.start / 1000000).toStringAsFixed(1)}M',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
                Text(
                  '₦${(_budgetRange.end / 1000000).toStringAsFixed(1)}M+',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
              ],
            ),
            RangeSlider(
              values: _budgetRange,
              min: 0,
              max: 100000000,
              divisions: 100,
              activeColor: const Color(0xFF309DAA),
              inactiveColor: const Color(0xFFF2F4F7),
              onChanged: (values) {
                setState(() => _budgetRange = values);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSortOption('recent', 'Most Recent'),
                const SizedBox(width: 12),
                _buildSortOption('oldest', 'Oldest First'),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final filters = MarketplaceFilters(
                    location: _locationController.text,
                    constructionType: _selectedType,
                    minBudget: _budgetRange.start,
                    maxBudget: _budgetRange.end,
                    orderBy: _orderBy,
                  );
                  ref.read(marketplaceFiltersProvider.notifier).state = filters;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276572),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    final isSelected = _orderBy == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _orderBy = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF309DAA) : const Color(0xFFD0D5DD),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? const Color(0xFF309DAA) : const Color(0xFF667085),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
