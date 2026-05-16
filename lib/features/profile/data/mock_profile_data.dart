import 'package:charity_managment/features/profile/domain/models/charity_profile.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/features/profile/domain/models/user.dart';

final mockDonorProfile = ProfileData(
  user: User(
    id: 'donor_01',
    name: 'Abel Donor',
    email: 'abel.donor@charity.app',
    role: ProfileRole.donor,
    bio: 'Passionate about community-driven impact and sustainable giving.',
    phone: '+1 555 120 4411',
    isVerified: true,
    createdAt: DateTime(2024, 4, 12),
    updatedAt: DateTime(2026, 5, 1),
  ),
  followedCampaignsCount: 6,
  donationCount: 14,
);

final mockCharityProfile = ProfileData(
  user: User(
    id: 'charity_01',
    name: 'Hope Charity',
    email: 'hello@hopecharity.org',
    role: ProfileRole.charity,
    phone: '+1 555 778 1022',
    isVerified: true,
    createdAt: DateTime(2023, 9, 20),
    updatedAt: DateTime(2026, 4, 8),
  ),
  charityProfile: CharityProfile(
    organizationName: 'Hope Charity',
    description: 'We provide food access and emergency relief to families in need.',
    documentUrl: 'https://example.org/charity/hope/documents/verification.pdf',
    phone: '+1 555 778 1022',
    address: '123 Hope Street, Springfield',
    website: 'https://hopecharity.org',
    verifiedAt: DateTime(2024, 2, 15),
  ),
  totalCampaignsCount: 5,
);
