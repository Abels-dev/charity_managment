import 'package:charity_managment/models/campaign.dart';

class CampaignFilters {
  const CampaignFilters({
    this.searchQuery = '',
    this.category,
    this.onlyActive = true,
  });

  final String searchQuery;
  final CampaignCategory? category;
  final bool onlyActive;

  CampaignFilters copyWith({
    String? searchQuery,
    CampaignCategory? category,
    bool clearCategory = false,
    bool? onlyActive,
  }) {
    return CampaignFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      category: clearCategory ? null : (category ?? this.category),
      onlyActive: onlyActive ?? this.onlyActive,
    );
  }
}
