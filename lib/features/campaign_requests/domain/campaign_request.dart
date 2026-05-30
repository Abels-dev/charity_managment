enum CampaignRequestStatus {
  pending,
  approved,
  rejected;

  String get label => switch (this) {
        CampaignRequestStatus.pending => 'Pending',
        CampaignRequestStatus.approved => 'Approved',
        CampaignRequestStatus.rejected => 'Rejected',
      };
}

class CampaignRequest {
  const CampaignRequest({
    required this.id,
    required this.charityName,
    required this.campaignTitle,
    required this.status,
    required this.requestedAt,
    this.message,
    this.reviewedAt,
    this.reviewedByName,
    this.monthCampaignCount,
    this.totalCampaignCount,
    this.activeCampaignCount,
  });

  final String id;
  final String charityName;
  final String campaignTitle;
  final CampaignRequestStatus status;
  final DateTime requestedAt;
  final String? message;
  final DateTime? reviewedAt;
  final String? reviewedByName;
  final int? monthCampaignCount;
  final int? totalCampaignCount;
  final int? activeCampaignCount;

  String get reason => campaignTitle;
}

class CampaignRequestSummary {
  const CampaignRequestSummary({
    required this.charityId,
    required this.organizationName,
    required this.currentMonthCampaignCount,
    required this.totalCampaignCount,
    required this.activeCampaignCount,
    required this.pendingRequestCount,
    required this.approvedAllowanceCount,
    required this.monthlyLimit,
    required this.hasExceededLimit,
    required this.hasApprovedAllowance,
  });

  final String charityId;
  final String organizationName;
  final int currentMonthCampaignCount;
  final int totalCampaignCount;
  final int activeCampaignCount;
  final int pendingRequestCount;
  final int approvedAllowanceCount;
  final int monthlyLimit;
  final bool hasExceededLimit;
  final bool hasApprovedAllowance;
}

class CharityCampaignRequestsResponse {
  const CharityCampaignRequestsResponse({
    required this.summary,
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.statusCounts,
  });

  final CampaignRequestSummary summary;
  final List<CampaignRequest> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final Map<CampaignRequestStatus, int> statusCounts;
}
