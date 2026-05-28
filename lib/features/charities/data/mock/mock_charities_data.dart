import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';

const seedCharities = [
  CharityPublicProfile(
    id: 'u_org_01',
    organizationName: 'Hope Foundation',
    description:
        'Empowering communities through education, healthcare, and sustainable initiatives.',
    phone: '+251-900-111-222',
    address: 'Addis Ababa, Ethiopia',
    website: 'https://hopefoundation.example.org',
    isVerified: true,
  ),
  CharityPublicProfile(
    id: 'u_org_02',
    organizationName: 'Care Outreach',
    description:
        'Delivering essential health and social support services to underserved regions.',
    phone: '+251-900-333-444',
    address: 'Afar Region, Ethiopia',
    website: 'https://careoutreach.example.org',
    isVerified: true,
  ),
  CharityPublicProfile(
    id: 'u_org_03',
    organizationName: 'Relief Hands',
    description:
        'Rapid response relief for emergencies, food insecurity, and displacement.',
    phone: '+251-900-555-666',
    address: 'Somali Region, Ethiopia',
    website: 'https://reliefhands.example.org',
    isVerified: false,
  ),
];
