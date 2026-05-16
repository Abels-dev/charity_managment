class CharityStats {
  const CharityStats({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.totalRaised,
    required this.totalDonors,
  });

  final int totalCampaigns;
  final int activeCampaigns;
  final double totalRaised;
  final int totalDonors;

  Map<String, dynamic> toJson() {
    return {
      'totalCampaigns': totalCampaigns,
      'activeCampaigns': activeCampaigns,
      'totalRaised': totalRaised,
      'totalDonors': totalDonors,
    };
  }

  factory CharityStats.fromJson(Map<String, dynamic> json) {
    return CharityStats(
      totalCampaigns: json['totalCampaigns'] as int,
      activeCampaigns: json['activeCampaigns'] as int,
      totalRaised: (json['totalRaised'] as num).toDouble(),
      totalDonors: json['totalDonors'] as int,
    );
  }
}
