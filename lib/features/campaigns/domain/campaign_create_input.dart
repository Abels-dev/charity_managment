class CampaignCreateInput {
  const CampaignCreateInput({
    required this.charityId,
    required this.charityName,
    required this.title,
    required this.description,
    required this.category,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
  });

  final String charityId;
  final String charityName;
  final String title;
  final String description;
  final String category;
  final double targetAmount;
  final DateTime startDate;
  final DateTime endDate;
}
