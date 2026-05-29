import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/repositories/charity_repository.dart';

import 'package:charity_managment/core/network/api_client.dart';
import 'package:charity_managment/features/charities/data/api_charity_repository.dart';

final charityRepositoryProvider = Provider<CharityRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiCharityRepository(dio);
});

final myCharityProfileProvider = FutureProvider<CharityPublicProfile?>((ref) async {
  final repository = ref.watch(charityRepositoryProvider);
  return repository.getMyProfile();
});

final charityPublicProfileProvider =
    FutureProvider.family<CharityPublicProfileDetails?, String>((ref, charityId) async {
  final repository = ref.watch(charityRepositoryProvider);
  final campaignRepository = ref.watch(campaignRepositoryProvider);

  final profile = await repository.getCharityById(charityId);
  if (profile == null) {
    return null;
  }

  // Fetch public campaigns and filter by charity id so public profiles
  // show the charity's campaigns (backend does not expose a dedicated
  // public campaigns-by-charity endpoint).
  final all = await campaignRepository.fetchCampaigns();
  final campaigns = all.where((c) => c.charityId == charityId).toList(growable: false);
  final stats = _buildStats(campaigns);

  return CharityPublicProfileDetails(
    profile: profile,
    stats: stats,
    campaigns: campaigns,
  );
});

CharityStats _buildStats(List<Campaign> campaigns) {
  final totalCampaigns = campaigns.length;
  final activeCampaigns =
      campaigns.where((campaign) => campaign.status == CampaignStatus.active).length;
  final totalRaised = campaigns.fold<double>(
    0,
    (sum, campaign) => sum + campaign.currentAmount,
  );
  final totalDonors = campaigns.fold<int>(
    0,
    (sum, campaign) => sum + campaign.donorCount,
  );

  return CharityStats(
    totalCampaigns: totalCampaigns,
    activeCampaigns: activeCampaigns,
    totalRaised: totalRaised,
    totalDonors: totalDonors,
  );
}
