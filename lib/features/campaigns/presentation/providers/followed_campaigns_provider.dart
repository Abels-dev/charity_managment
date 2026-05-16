import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/models/campaign.dart';

final followedCampaignsProvider = FutureProvider<List<Campaign>>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getFollowedCampaigns();
});
