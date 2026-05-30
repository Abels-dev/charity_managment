class CharityProfile {
  const CharityProfile({
    required this.organizationName,
    this.description,
    this.documentUrl,
    this.phone,
    this.address,
    this.website,
    this.socialFacebook,
    this.socialTelegram,
    this.socialInstagram,
    this.socialTwitter,
    this.socialYoutube,
    this.socialTiktok,
    this.verifiedAt,
  });

  final String organizationName;
  final String? description;
  final String? documentUrl;
  final String? phone;
  final String? address;
  final String? website;
  final String? socialFacebook;
  final String? socialTelegram;
  final String? socialInstagram;
  final String? socialTwitter;
  final String? socialYoutube;
  final String? socialTiktok;
  final DateTime? verifiedAt;

  CharityProfile copyWith({
    String? organizationName,
    String? description,
    String? documentUrl,
    String? phone,
    String? address,
    String? website,
    String? socialFacebook,
    String? socialTelegram,
    String? socialInstagram,
    String? socialTwitter,
    String? socialYoutube,
    String? socialTiktok,
    DateTime? verifiedAt,
  }) {
    return CharityProfile(
      organizationName: organizationName ?? this.organizationName,
      description: description ?? this.description,
      documentUrl: documentUrl ?? this.documentUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      socialFacebook: socialFacebook ?? this.socialFacebook,
      socialTelegram: socialTelegram ?? this.socialTelegram,
      socialInstagram: socialInstagram ?? this.socialInstagram,
      socialTwitter: socialTwitter ?? this.socialTwitter,
      socialYoutube: socialYoutube ?? this.socialYoutube,
      socialTiktok: socialTiktok ?? this.socialTiktok,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationName': organizationName,
      'description': description,
      'documentUrl': documentUrl,
      'phone': phone,
      'address': address,
      'website': website,
      'socialFacebook': socialFacebook,
      'socialTelegram': socialTelegram,
      'socialInstagram': socialInstagram,
      'socialTwitter': socialTwitter,
      'socialYoutube': socialYoutube,
      'socialTiktok': socialTiktok,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  factory CharityProfile.fromJson(Map<String, dynamic> json) {
    return CharityProfile(
      organizationName: json['organizationName'] as String,
      description: json['description'] as String?,
      documentUrl: json['documentUrl'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      socialFacebook: json['socialFacebook'] as String?,
      socialTelegram: json['socialTelegram'] as String?,
      socialInstagram: json['socialInstagram'] as String?,
      socialTwitter: json['socialTwitter'] as String?,
      socialYoutube: json['socialYoutube'] as String?,
      socialTiktok: json['socialTiktok'] as String?,
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
    );
  }
}
