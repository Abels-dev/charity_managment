class DashboardSummary {
  const DashboardSummary({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.closedCampaigns,
    required this.totalRaised,
    required this.totalDonors,
  });

  final int totalCampaigns;
  final int activeCampaigns;
  final int closedCampaigns;
  final double totalRaised;
  final int totalDonors;

  bool get hasCampaigns => totalCampaigns > 0;

  static const empty = DashboardSummary(
    totalCampaigns: 0,
    activeCampaigns: 0,
    closedCampaigns: 0,
    totalRaised: 0,
    totalDonors: 0,
  );
}
