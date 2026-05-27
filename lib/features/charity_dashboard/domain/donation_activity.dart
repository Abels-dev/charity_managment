class DonationActivity {
  const DonationActivity({
    required this.donationId,
    required this.donorName,
    required this.amount,
    required this.campaignName,
    required this.donatedAt,
    required this.isAnonymous,
  });

  final String donationId;
  final String donorName;
  final double amount;
  final String campaignName;
  final DateTime donatedAt;
  final bool isAnonymous;
}
