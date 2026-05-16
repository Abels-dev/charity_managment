import 'package:charity_managment/features/campaigns/domain/campaign_create_input.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_filters.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_update_input.dart';
import 'package:charity_managment/models/campaign.dart';

abstract class CampaignRepository {
  Future<List<Campaign>> fetchCampaigns({
    CampaignFilters filters = const CampaignFilters(),
  });

  Future<Campaign?> getCampaignById(String campaignId);

  Future<Set<String>> getFollowedCampaignIds();

  Future<void> setCampaignFollowed({
    required String campaignId,
    required bool followed,
  });

  Future<List<Campaign>> getMyCampaigns(String charityId);

  Future<List<Campaign>> getFollowedCampaigns();

  Future<Campaign> createCampaign(CampaignCreateInput input);

  Future<Campaign> updateCampaign(CampaignUpdateInput input);

  Future<Campaign> closeCampaign(String campaignId);
}
