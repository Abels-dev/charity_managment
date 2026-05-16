import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/data/local/campaign_local_storage.dart';
import 'package:charity_managment/features/campaigns/data/mock_campaign_repository.dart';
import 'package:charity_managment/repositories/campaign_repository.dart';

final campaignLocalStorageProvider = Provider<CampaignLocalStorage>((ref) {
  return CampaignLocalStorage();
});

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final localStorage = ref.watch(campaignLocalStorageProvider);
  return MockCampaignRepository(localStorage);
});
