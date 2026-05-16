import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/models/campaign.dart';

final campaignDetailProvider =
    FutureProvider.family<Campaign?, String>((ref, campaignId) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getCampaignById(campaignId);
});
