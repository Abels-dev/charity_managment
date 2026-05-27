import 'package:charity_managment/features/charity_dashboard/domain/campaign_analytics.dart';
import 'package:charity_managment/features/charity_dashboard/domain/dashboard_summary.dart';
import 'package:charity_managment/features/charity_dashboard/domain/donation_activity.dart';
import 'package:charity_managment/models/charity_stats.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary({
    required String charityId,
  });

  Future<List<DonationActivity>> getRecentDonations({
    required String charityId,
    int limit = 5,
  });

  Future<List<CampaignAnalytics>> getCampaignAnalytics({
    required String charityId,
  });

  Future<CharityStats> fetchCharityStats();
}
