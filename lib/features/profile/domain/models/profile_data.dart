import 'charity_profile.dart';
import 'user.dart';

class ProfileData {
  const ProfileData({
    required this.user,
    this.charityProfile,
    this.followedCampaignsCount = 0,
    this.donationCount = 0,
    this.totalCampaignsCount = 0,
  });

  final User user;
  final CharityProfile? charityProfile;
  final int followedCampaignsCount;
  final int donationCount;
  final int totalCampaignsCount;

  ProfileData copyWith({
    User? user,
    CharityProfile? charityProfile,
    int? followedCampaignsCount,
    int? donationCount,
    int? totalCampaignsCount,
  }) {
    return ProfileData(
      user: user ?? this.user,
      charityProfile: charityProfile ?? this.charityProfile,
      followedCampaignsCount: followedCampaignsCount ?? this.followedCampaignsCount,
      donationCount: donationCount ?? this.donationCount,
      totalCampaignsCount: totalCampaignsCount ?? this.totalCampaignsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'charityProfile': charityProfile?.toJson(),
      'followedCampaignsCount': followedCampaignsCount,
      'donationCount': donationCount,
      'totalCampaignsCount': totalCampaignsCount,
    };
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      charityProfile: json['charityProfile'] == null
          ? null
          : CharityProfile.fromJson(
              json['charityProfile'] as Map<String, dynamic>,
            ),
      followedCampaignsCount: json['followedCampaignsCount'] as int? ?? 0,
      donationCount: json['donationCount'] as int? ?? 0,
      totalCampaignsCount: json['totalCampaignsCount'] as int? ?? 0,
    );
  }
}
