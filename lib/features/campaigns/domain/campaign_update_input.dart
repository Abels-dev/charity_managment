class CampaignUpdateInput {
  const CampaignUpdateInput({
    required this.campaignId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetAmount,
    required this.endDate,
  });

  final String campaignId;
  final String title;
  final String description;
  final String imageUrl;
  final double targetAmount;
  final DateTime endDate;
}
