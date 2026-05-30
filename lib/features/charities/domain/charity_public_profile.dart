import 'package:charity_managment/features/bank_accounts/data/api_bank_account_repository.dart';
import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/models/campaign.dart';

class CharityPublicProfile {
  const CharityPublicProfile({
    required this.id,
    required this.organizationName,
    this.description,
    this.logo,
    this.status,
    this.verifiedAt,
    this.phone,
    this.address,
    this.website,
    this.socialFacebook,
    this.socialTelegram,
    this.socialInstagram,
    this.socialTwitter,
    this.socialYoutube,
    this.socialTiktok,
    this.bankAccounts = const [],
    this.isVerified = false,
  });

  final String id;
  final String organizationName;
  final String? description;
  final String? logo;
  final String? status;
  final DateTime? verifiedAt;
  final String? phone;
  final String? address;
  final String? website;
  final String? socialFacebook;
  final String? socialTelegram;
  final String? socialInstagram;
  final String? socialTwitter;
  final String? socialYoutube;
  final String? socialTiktok;
  final List<BankAccount> bankAccounts;
  final bool isVerified;

  CharityPublicProfile copyWith({
    String? id,
    String? organizationName,
    String? description,
    String? logo,
    String? status,
    DateTime? verifiedAt,
    String? phone,
    String? address,
    String? website,
    String? socialFacebook,
    String? socialTelegram,
    String? socialInstagram,
    String? socialTwitter,
    String? socialYoutube,
    String? socialTiktok,
    List<BankAccount>? bankAccounts,
    bool? isVerified,
  }) {
    return CharityPublicProfile(
      id: id ?? this.id,
      organizationName: organizationName ?? this.organizationName,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      socialFacebook: socialFacebook ?? this.socialFacebook,
      socialTelegram: socialTelegram ?? this.socialTelegram,
      socialInstagram: socialInstagram ?? this.socialInstagram,
      socialTwitter: socialTwitter ?? this.socialTwitter,
      socialYoutube: socialYoutube ?? this.socialYoutube,
      socialTiktok: socialTiktok ?? this.socialTiktok,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  factory CharityPublicProfile.fromJson(Map<String, dynamic> json) {
    final bankAccountsJson = (json['bankAccounts'] as List?) ?? const [];

    return CharityPublicProfile(
      id: json['id']?.toString() ?? '',
      organizationName: json['organizationName']?.toString() ?? 'Unknown',
      description: json['description']?.toString(),
      logo: json['logo']?.toString(),
      status: json['status']?.toString(),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.tryParse(json['verifiedAt'].toString()),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      website: json['website']?.toString(),
      socialFacebook: json['socialFacebook']?.toString(),
      socialTelegram: json['socialTelegram']?.toString(),
      socialInstagram: json['socialInstagram']?.toString(),
      socialTwitter: json['socialTwitter']?.toString(),
      socialYoutube: json['socialYoutube']?.toString(),
      socialTiktok: json['socialTiktok']?.toString(),
      bankAccounts: bankAccountsJson
          .whereType<Map>()
          .map((e) => BankAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      isVerified: (json['status']?.toString().toUpperCase() == 'APPROVED') ||
          json['verifiedAt'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationName': organizationName,
      'description': description,
      'logo': logo,
      'status': status,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'phone': phone,
      'address': address,
      'website': website,
      'socialFacebook': socialFacebook,
      'socialTelegram': socialTelegram,
      'socialInstagram': socialInstagram,
      'socialTwitter': socialTwitter,
      'socialYoutube': socialYoutube,
      'socialTiktok': socialTiktok,
      'bankAccounts': bankAccounts.map((account) => account.toJson()).toList(growable: false),
      'isVerified': isVerified,
    };
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
