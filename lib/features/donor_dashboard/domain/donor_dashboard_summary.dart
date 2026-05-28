class DonorDashboardSummary {
  const DonorDashboardSummary({
    required this.totalDonated,
    required this.campaignsSupported,
    required this.monthlyTotal,
    required this.activeFollowed,
    required this.anonymousCount,
  });

  final double totalDonated;
  final int campaignsSupported;
  final double monthlyTotal;
  final int activeFollowed;
  final int anonymousCount;
}
