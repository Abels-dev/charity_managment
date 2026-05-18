class DonationCreateInput {
  const DonationCreateInput({
    required this.donorId,
    required this.campaignId,
    required this.amount,
    required this.isAnonymous,
    this.message,
  });

  final String donorId;
  final String campaignId;
  final double amount;
  final bool isAnonymous;
  final String? message;
}
