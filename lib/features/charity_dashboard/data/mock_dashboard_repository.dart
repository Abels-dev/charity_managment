import 'package:charity_managment/features/charity_dashboard/domain/campaign_analytics.dart';
import 'package:charity_managment/features/charity_dashboard/domain/dashboard_summary.dart';
import 'package:charity_managment/features/charity_dashboard/domain/donation_activity.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/repositories/campaign_repository.dart';
import 'package:charity_managment/repositories/dashboard_repository.dart';
import 'package:charity_managment/repositories/donation_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository({
    required CampaignRepository campaignRepository,
    required DonationRepository donationRepository,
  })  : _campaignRepository = campaignRepository,
        _donationRepository = donationRepository;

  final CampaignRepository _campaignRepository;
  final DonationRepository _donationRepository;

  @override
  Future<DashboardSummary> getDashboardSummary({
    required String charityId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final campaigns = await _campaignRepository.getMyCampaigns(charityId);
    final donations = await _donationsForCampaigns(campaigns);

    final completed = donations.where((donation) {
      return donation.status == DonationStatus.completed;
    }).toList(growable: false);

    final totalRaised = completed.fold<double>(
      0,
      (total, donation) => total + donation.amount,
    );

    final totalDonors = completed
        .map((donation) => donation.donorId)
        .toSet()
        .length;

    final activeCampaigns = campaigns
        .where((campaign) => campaign.status == CampaignStatus.active)
        .length;
    final closedCampaigns = campaigns
        .where((campaign) => campaign.status == CampaignStatus.closed)
        .length;

    return DashboardSummary(
      totalCampaigns: campaigns.length,
      activeCampaigns: activeCampaigns,
      closedCampaigns: closedCampaigns,
      totalRaised: totalRaised,
      totalDonors: totalDonors,
    );
  }

  @override
  Future<List<DonationActivity>> getRecentDonations({
    required String charityId,
    int limit = 5,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final campaigns = await _campaignRepository.getMyCampaigns(charityId);
    final donations = (await _donationsForCampaigns(campaigns))
      .where((donation) => donation.status == DonationStatus.completed)
      .toList(growable: false);

    donations.sort((a, b) => b.donatedAt.compareTo(a.donatedAt));

    final campaignLookup = {
      for (final campaign in campaigns) campaign.id: campaign,
    };

    return donations.take(limit).map((donation) {
      final campaign = campaignLookup[donation.campaignId];
      return DonationActivity(
        donationId: donation.id,
        donorName: _donorLabel(donation),
        amount: donation.amount,
        campaignName: campaign?.title ?? 'Unknown campaign',
        donatedAt: donation.donatedAt,
        isAnonymous: donation.isAnonymous,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<CampaignAnalytics>> getCampaignAnalytics({
    required String charityId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final campaigns = await _campaignRepository.getMyCampaigns(charityId);
    return campaigns
        .map(
          (campaign) => CampaignAnalytics(
            campaignId: campaign.id,
            title: campaign.title,
            status: campaign.status,
            currentAmount: campaign.currentAmount,
            targetAmount: campaign.targetAmount,
            donorCount: campaign.donorCount,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<CharityStats> fetchCharityStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final summary = await getDashboardSummary(charityId: '');
    return CharityStats(
      totalCampaigns: summary.totalCampaigns,
      activeCampaigns: summary.activeCampaigns,
      totalRaised: summary.totalRaised,
      totalDonors: summary.totalDonors,
    );
  }

  Future<List<Donation>> _donationsForCampaigns(List<Campaign> campaigns) async {
    if (campaigns.isEmpty) return const <Donation>[];
    final ids = campaigns.map((campaign) => campaign.id).toSet();
    return _donationRepository.getDonationsByCampaignIds(ids);
  }

  String _donorLabel(Donation donation) {
    if (donation.isAnonymous) {
      return 'Anonymous';
    }

    final sanitized = donation.donorId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (sanitized.isEmpty) {
      return 'Donor';
    }

    final suffix = sanitized.length <= 6
        ? sanitized.toUpperCase()
        : sanitized.substring(sanitized.length - 6).toUpperCase();
    return 'Donor $suffix';
  }
}
