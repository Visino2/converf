class MarketplaceFilters {
  final String? searchQuery;
  final String? location;
  final String? constructionType;
  final double? minBudget;
  final double? maxBudget;
  final String? orderBy; // 'recent', 'oldest'

  MarketplaceFilters({
    this.searchQuery,
    this.location,
    this.constructionType,
    this.minBudget,
    this.maxBudget,
    this.orderBy = 'recent',
  });

  MarketplaceFilters copyWith({
    String? searchQuery,
    String? location,
    String? constructionType,
    double? minBudget,
    double? maxBudget,
    String? orderBy,
  }) {
    return MarketplaceFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      location: location ?? this.location,
      constructionType: constructionType ?? this.constructionType,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      orderBy: orderBy ?? this.orderBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (searchQuery != null && searchQuery!.isNotEmpty) 'search': searchQuery,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (constructionType != null && constructionType != 'all') 'type': constructionType,
      if (minBudget != null) 'min_budget': minBudget,
      if (maxBudget != null) 'max_budget': maxBudget,
      if (orderBy != null) 'order_by': orderBy,
    };
  }

  bool get isEmpty =>
      (searchQuery == null || searchQuery!.isEmpty) &&
      (location == null || location!.isEmpty) &&
      (constructionType == null || constructionType == 'all') &&
      minBudget == null &&
      maxBudget == null &&
      orderBy == 'recent';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceFilters &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          location == other.location &&
          constructionType == other.constructionType &&
          minBudget == other.minBudget &&
          maxBudget == other.maxBudget &&
          orderBy == other.orderBy;

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      location.hashCode ^
      constructionType.hashCode ^
      minBudget.hashCode ^
      maxBudget.hashCode ^
      orderBy.hashCode;
}
