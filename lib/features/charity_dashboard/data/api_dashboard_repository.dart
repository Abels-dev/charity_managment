import 'package:charity_managment/features/charity_dashboard/domain/campaign_analytics.dart';
import 'package:charity_managment/features/charity_dashboard/domain/dashboard_summary.dart';
import 'package:charity_managment/features/charity_dashboard/domain/donation_activity.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/repositories/dashboard_repository.dart';
import 'package:dio/dio.dart';

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._dio);

  final Dio _dio;

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Future<DashboardSummary> getDashboardSummary({required String charityId}) async {
    try {
      final response = await _dio.get('/api/charity-dashboard/overview');
      final data = response.data['data']?['stats'] ?? const {};
      return DashboardSummary(
        totalCampaigns: data['totalCampaigns'] ?? 0,
        activeCampaigns: data['activeCampaigns'] ?? 0,
        closedCampaigns: data['closedCampaigns'] ?? 0,
        totalRaised: _asDouble(data['totalRaised']),
        totalDonors: data['totalDonors'] ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard summary');
    }
  }

  @override
  Future<List<DonationActivity>> getRecentDonations({
    required String charityId,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get('/api/charity-dashboard/overview');
      final List data = response.data['data']?['recentContributions'] ?? const [];
      return data.take(limit).map((json) {
        return DonationActivity(
          donationId: json['id']?.toString() ?? '',
          donorName: (json['isAnonymous'] ?? false) ? 'Anonymous' : (json['donor']?['name'] ?? json['guestName'] ?? 'Donor'),
          amount: _asDouble(json['amount']),
          campaignName: json['campaign']?['title'] ?? 'Unknown campaign',
          donatedAt: json['donatedAt'] != null ? DateTime.parse(json['donatedAt'].toString()) : DateTime.now(),
          isAnonymous: json['isAnonymous'] ?? false,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CampaignAnalytics>> getCampaignAnalytics({required String charityId}) async {
    try {
      final response = await _dio.get('/api/charity-dashboard/campaigns');
      final List data = response.data['data']?['items'] ?? const [];
      return data.map((json) {
        return CampaignAnalytics(
          campaignId: json['id'].toString(),
          title: json['title'] ?? '',
          status: _mapStatus(json['status']),
          currentAmount: _asDouble(json['currentAmount']),
          targetAmount: _asDouble(json['targetAmount']),
          donorCount: json['donorCount'] ?? json['_count']?['donations'] ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CharityStats> fetchCharityStats() async {
    try {
      final response = await _dio.get('/api/stats/platform');
      final data = response.data['data'] ?? const {};
      return CharityStats(
        totalCampaigns: data['totalCampaigns'] ?? 0,
        activeCampaigns: data['activeCampaigns'] ?? 0,
        totalRaised: _asDouble(data['totalDonationsAmount']),
        totalDonors: data['totalDonors'] ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch platform stats');
    }
  }

  CampaignStatus _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CLOSED':
        return CampaignStatus.closed;
      case 'DRAFT':
        return CampaignStatus.draft;
      case 'ACTIVE':
      default:
        return CampaignStatus.active;
    }
  }
}
