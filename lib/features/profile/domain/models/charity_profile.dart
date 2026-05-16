class CharityProfile {
  const CharityProfile({
    required this.organizationName,
    this.description,
    this.documentUrl,
    this.phone,
    this.address,
    this.website,
    this.verifiedAt,
  });

  final String organizationName;
  final String? description;
  final String? documentUrl;
  final String? phone;
  final String? address;
  final String? website;
  final DateTime? verifiedAt;

  CharityProfile copyWith({
    String? organizationName,
    String? description,
    String? documentUrl,
    String? phone,
    String? address,
    String? website,
    DateTime? verifiedAt,
  }) {
    return CharityProfile(
      organizationName: organizationName ?? this.organizationName,
      description: description ?? this.description,
      documentUrl: documentUrl ?? this.documentUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
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
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
    );
  }
}
