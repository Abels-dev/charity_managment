import 'package:charity_managment/features/campaigns/data/local/campaign_local_storage.dart';
import 'package:charity_managment/features/campaigns/data/mock/mock_campaigns_data.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_filters.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/repositories/campaign_repository.dart';

class MockCampaignRepository implements CampaignRepository {
  MockCampaignRepository(this._localStorage);

  final CampaignLocalStorage _localStorage;

  @override
  Future<List<Campaign>> fetchCampaigns({
    CampaignFilters filters = const CampaignFilters(),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final query = filters.searchQuery.trim().toLowerCase();

    return mockCampaigns.where((campaign) {
      if (filters.onlyActive && !campaign.isActive) {
        return false;
      }

      if (filters.category != null && campaign.category != filters.category) {
        return false;
      }

      if (query.isNotEmpty) {
        final inTitle = campaign.title.toLowerCase().contains(query);
        final inSummary = campaign.summary.toLowerCase().contains(query);
        final inOrg = campaign.organizationName.toLowerCase().contains(query);

        if (!inTitle && !inSummary && !inOrg) {
          return false;
        }
      }

      return true;
    }).toList(growable: false);
  }

  @override
  Future<Campaign?> getCampaignById(String campaignId) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    for (final campaign in mockCampaigns) {
      if (campaign.id == campaignId) {
        return campaign;
      }
    }

    return null;
  }

  @override
  Future<Set<String>> getFollowedCampaignIds() async {
    await Future<void>.delayed(const Duration(milliseconds: 130));
    return _localStorage.readFollowedCampaignIds();
  }

  @override
  Future<void> setCampaignFollowed({
    required String campaignId,
    required bool followed,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 130));

    final ids = await _localStorage.readFollowedCampaignIds();
    final next = <String>{...ids};

    if (followed) {
      next.add(campaignId);
    } else {
      next.remove(campaignId);
    }

    await _localStorage.saveFollowedCampaignIds(next);
  }
}
