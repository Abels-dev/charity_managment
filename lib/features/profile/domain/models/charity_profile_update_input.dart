class CharityProfileUpdateInput {
  const CharityProfileUpdateInput({
    required this.organizationName,
    required this.description,
    required this.phone,
    required this.website,
    required this.address,
    this.socialFacebook,
    this.socialTelegram,
    this.socialInstagram,
    this.socialTwitter,
    this.socialYoutube,
    this.socialTiktok,
  });

  final String organizationName;
  final String? description;
  final String? phone;
  final String? website;
  final String? address;
  final String? socialFacebook;
  final String? socialTelegram;
  final String? socialInstagram;
  final String? socialTwitter;
  final String? socialYoutube;
  final String? socialTiktok;
}
