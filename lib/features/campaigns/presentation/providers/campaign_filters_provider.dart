import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/domain/campaign_filters.dart';
import 'package:charity_managment/models/campaign.dart';

class CampaignFiltersController extends StateNotifier<CampaignFilters> {
  CampaignFiltersController() : super(const CampaignFilters());

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setCategory(CampaignCategory? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
      return;
    }

    state = state.copyWith(category: category);
  }
}

final campaignFiltersProvider =
    StateNotifierProvider<CampaignFiltersController, CampaignFilters>((ref) {
  return CampaignFiltersController();
});
