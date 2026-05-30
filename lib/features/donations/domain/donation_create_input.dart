class DonationCreateInput {
  const DonationCreateInput({
    this.donorId,
    this.donorName,
    this.donorEmail,
    required this.campaignId,
    required this.amount,
    required this.isAnonymous,
    this.message,
  });

  final String? donorId;
  final String? donorName;
  final String? donorEmail;
  final String campaignId;
  final double amount;
  final bool isAnonymous;
  final String? message;
}
