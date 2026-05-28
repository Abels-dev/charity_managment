import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/domain/campaign_filters.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/models/campaign.dart';

final featuredCampaignsProvider = FutureProvider<List<Campaign>>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  final campaigns = await repository.fetchCampaigns(
    filters: const CampaignFilters(onlyActive: true),
  );
  return campaigns.take(3).toList(growable: false);
});
