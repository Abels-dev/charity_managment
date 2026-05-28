import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/models/campaign.dart';

class CharityPublicProfile {
  const CharityPublicProfile({
    required this.id,
    required this.organizationName,
    this.description,
    this.phone,
    this.address,
    this.website,
    this.isVerified = false,
  });

  final String id;
  final String organizationName;
  final String? description;
  final String? phone;
  final String? address;
  final String? website;
  final bool isVerified;

  CharityPublicProfile copyWith({
    String? id,
    String? organizationName,
    String? description,
    String? phone,
    String? address,
    String? website,
    bool? isVerified,
  }) {
    return CharityPublicProfile(
      id: id ?? this.id,
      organizationName: organizationName ?? this.organizationName,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class CharityPublicProfileDetails {
  const CharityPublicProfileDetails({
    required this.profile,
    required this.stats,
    required this.campaigns,
  });

  final CharityPublicProfile profile;
  final CharityStats stats;
  final List<Campaign> campaigns;
}
