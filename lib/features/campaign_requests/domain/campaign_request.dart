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
  });

  final String id;
  final String charityName;
  final String campaignTitle;
  final CampaignRequestStatus status;
  final DateTime requestedAt;
  final String? message;
}
