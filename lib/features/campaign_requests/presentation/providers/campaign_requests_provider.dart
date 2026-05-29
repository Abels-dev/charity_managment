import 'package:charity_managment/core/network/api_client.dart';
import 'package:charity_managment/features/campaign_requests/data/api_campaign_request_repository.dart';
import 'package:charity_managment/features/campaign_requests/domain/campaign_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final campaignRequestRepositoryProvider = Provider<ApiCampaignRequestRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiCampaignRequestRepository(dio);
});

final campaignRequestsProvider = FutureProvider<List<CampaignRequest>>((ref) async {
  final repository = ref.watch(campaignRequestRepositoryProvider);
  return repository.getAdminCampaignRequests();
});
