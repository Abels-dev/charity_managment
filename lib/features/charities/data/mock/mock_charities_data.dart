import 'package:charity_managment/features/bank_accounts/data/api_bank_account_repository.dart';
import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';

final seedCharities = [
  CharityPublicProfile(
    id: 'u_org_01',
    organizationName: 'Hope Foundation',
    description:
        'Empowering communities through education, healthcare, and sustainable initiatives.',
    phone: '+251-900-111-222',
    address: 'Addis Ababa, Ethiopia',
    website: 'https://hopefoundation.example.org',
    socialFacebook: 'facebook.com/hopefoundation',
    socialTelegram: 't.me/hopefoundation',
    socialInstagram: 'instagram.com/hopefoundation',
    socialTwitter: 'x.com/hopefoundation',
    socialYoutube: 'youtube.com/@hopefoundation',
    socialTiktok: 'tiktok.com/@hopefoundation',
    bankAccounts: [
      BankAccount(
        id: 'bank_01',
        accountNumber: '9123456789',
        accountHolder: 'Hope Foundation',
        bankName: 'Commercial Bank of Ethiopia',
        type: 'PERSONAL',
        isPrimary: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ],
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
    socialFacebook: 'facebook.com/careoutreach',
    socialTelegram: 't.me/careoutreach',
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
    socialInstagram: 'instagram.com/reliefhands',
    socialTwitter: 'x.com/reliefhands',
    isVerified: false,
  ),
];
