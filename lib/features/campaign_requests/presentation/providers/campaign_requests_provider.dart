import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaign_requests/data/mock/mock_campaign_requests.dart';
import 'package:charity_managment/features/campaign_requests/domain/campaign_request.dart';

final campaignRequestsProvider = FutureProvider<List<CampaignRequest>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 220));
  return mockCampaignRequests;
});
