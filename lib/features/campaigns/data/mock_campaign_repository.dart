import 'package:charity_managment/features/campaigns/data/local/campaign_local_storage.dart';
import 'package:charity_managment/features/campaigns/data/mock/mock_campaigns_data.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_create_input.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_filters.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_update_input.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/repositories/campaign_repository.dart';

class MockCampaignRepository implements CampaignRepository {
  MockCampaignRepository(this._localStorage);

  final CampaignLocalStorage _localStorage;

  static final List<Campaign> _campaigns = List<Campaign>.from(seedCampaigns);

  @override
  Future<List<Campaign>> fetchCampaigns({
    CampaignFilters filters = const CampaignFilters(),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 380));

    final query = filters.searchQuery.trim().toLowerCase();

    final results = _campaigns.where((campaign) {
      if (filters.onlyActive && campaign.status != CampaignStatus.active) {
        return false;
      }

      if (filters.category != null && campaign.category != filters.category) {
        return false;
      }

      if (query.isNotEmpty) {
        final inTitle = campaign.title.toLowerCase().contains(query);
        final inDescription = campaign.description.toLowerCase().contains(query);
        final inCharity = campaign.charityName.toLowerCase().contains(query);

        if (!inTitle && !inDescription && !inCharity) {
          return false;
        }
      }

      return true;
    }).toList(growable: false);

    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results;
  }

  @override
  Future<Campaign?> getCampaignById(String campaignId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    for (final campaign in _campaigns) {
      if (campaign.id == campaignId) {
        return campaign;
      }
    }

    return null;
  }

  @override
  Future<Set<String>> getFollowedCampaignIds() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _localStorage.readFollowedCampaignIds();
  }

  @override
  Future<void> setCampaignFollowed({
    required String campaignId,
    required bool followed,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final ids = await _localStorage.readFollowedCampaignIds();
    final next = <String>{...ids};

    if (followed) {
      next.add(campaignId);
    } else {
      next.remove(campaignId);
    }

    await _localStorage.saveFollowedCampaignIds(next);
  }

  @override
  Future<List<Campaign>> getMyCampaigns(String charityId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final mine = _campaigns
        .where((campaign) => campaign.charityId == charityId)
        .toList(growable: false);

    mine.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return mine;
  }

  @override
  Future<List<Campaign>> getFollowedCampaigns() async {
    final ids = await _localStorage.readFollowedCampaignIds();

    final followed = _campaigns
        .where((campaign) => ids.contains(campaign.id))
        .toList(growable: false);

    followed.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return followed;
  }

  @override
  Future<Campaign> createCampaign(CampaignCreateInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final now = DateTime.now();
    final created = Campaign(
      id: _nextId(),
      charityId: input.charityId,
      charityName: input.charityName,
      title: input.title.trim(),
      description: input.description.trim(),
      imageUrl: input.imageUrl.trim(),
      targetAmount: input.targetAmount,
      currentAmount: 0,
      donorCount: 0,
      startDate: input.startDate,
      endDate: input.endDate,
      createdAt: now,
      updatedAt: now,
      status: CampaignStatus.active,
      category: CampaignCategory.emergency,
    );

    _campaigns.add(created);
    return created;
  }

  @override
  Future<Campaign> updateCampaign(CampaignUpdateInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final index = _campaigns.indexWhere((campaign) => campaign.id == input.campaignId);
    if (index < 0) {
      throw StateError('Campaign not found.');
    }

    final existing = _campaigns[index];
    if (existing.status == CampaignStatus.closed) {
      throw StateError('Closed campaigns cannot be edited.');
    }

    final updated = existing.copyWith(
      title: input.title.trim(),
      description: input.description.trim(),
      imageUrl: input.imageUrl.trim(),
      targetAmount: input.targetAmount,
      endDate: input.endDate,
      updatedAt: DateTime.now(),
    );

    _campaigns[index] = updated;
    return updated;
  }

  @override
  Future<Campaign> closeCampaign(String campaignId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final index = _campaigns.indexWhere((campaign) => campaign.id == campaignId);
    if (index < 0) {
      throw StateError('Campaign not found.');
    }

    final current = _campaigns[index];
    if (current.status == CampaignStatus.closed) {
      return current;
    }

    final closed = current.copyWith(
      status: CampaignStatus.closed,
      updatedAt: DateTime.now(),
    );

    _campaigns[index] = closed;
    return closed;
  }

  @override
  Future<Campaign> applyDonation({
    required String campaignId,
    required double amount,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final index = _campaigns.indexWhere((campaign) => campaign.id == campaignId);
    if (index < 0) {
      throw StateError('Campaign not found.');
    }

    final current = _campaigns[index];
    final updated = current.copyWith(
      currentAmount: current.currentAmount + amount,
      donorCount: current.donorCount + 1,
      updatedAt: DateTime.now(),
    );

    _campaigns[index] = updated;
    return updated;
  }

  String _nextId() {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'cmp_$stamp';
  }
}
