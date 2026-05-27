import 'package:charity_managment/models/campaign.dart';

class CampaignAnalytics {
  const CampaignAnalytics({
    required this.campaignId,
    required this.title,
    required this.status,
    required this.currentAmount,
    required this.targetAmount,
    required this.donorCount,
  });

  final String campaignId;
  final String title;
  final CampaignStatus status;
  final double currentAmount;
  final double targetAmount;
  final int donorCount;

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0, 1);
  }

  bool get isClosed => status == CampaignStatus.closed;
  bool get isActive => status == CampaignStatus.active;
}
