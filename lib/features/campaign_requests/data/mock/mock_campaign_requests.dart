import 'package:charity_managment/features/campaign_requests/domain/campaign_request.dart';

final mockCampaignRequests = [
  CampaignRequest(
    id: 'rq_001',
    charityName: 'Hope Foundation',
    campaignTitle: 'School Kits for Rural Children',
    status: CampaignRequestStatus.pending,
    requestedAt: DateTime(2026, 5, 15, 11, 20),
    message: 'Need approval for the new education drive.',
  ),
  CampaignRequest(
    id: 'rq_002',
    charityName: 'Care Outreach',
    campaignTitle: 'Mobile Clinic Outreach',
    status: CampaignRequestStatus.approved,
    requestedAt: DateTime(2026, 5, 12, 9, 5),
  ),
  CampaignRequest(
    id: 'rq_003',
    charityName: 'Relief Hands',
    campaignTitle: 'Emergency Food Support',
    status: CampaignRequestStatus.rejected,
    requestedAt: DateTime(2026, 5, 10, 13, 45),
    message: 'Please provide a clearer budget breakdown.',
  ),
];
