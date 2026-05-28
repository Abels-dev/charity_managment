import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/charities/data/mock_charity_repository.dart';
import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/repositories/charity_repository.dart';

final charityRepositoryProvider = Provider<CharityRepository>((ref) {
  return MockCharityRepository();
});

final charityPublicProfileProvider =
    FutureProvider.family<CharityPublicProfileDetails?, String>((ref, charityId) async {
  final repository = ref.watch(charityRepositoryProvider);
  final campaignRepository = ref.watch(campaignRepositoryProvider);

  final profile = await repository.getCharityById(charityId);
  if (profile == null) {
    return null;
  }

  final campaigns = await campaignRepository.getMyCampaigns(charityId);
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
