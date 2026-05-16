import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_filters_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/models/campaign.dart';

final campaignsListProvider = FutureProvider<List<Campaign>>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  final filters = ref.watch(campaignFiltersProvider);

  return repository.fetchCampaigns(filters: filters);
});
