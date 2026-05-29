import 'package:charity_managment/core/network/api_client.dart';
import 'package:charity_managment/features/campaigns/data/api_campaign_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/data/local/campaign_local_storage.dart';
import 'package:charity_managment/repositories/campaign_repository.dart';

final campaignLocalStorageProvider = Provider<CampaignLocalStorage>((ref) {
  return CampaignLocalStorage();
});

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiCampaignRepository(dio);
});
