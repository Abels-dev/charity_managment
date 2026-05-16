import 'package:charity_managment/models/campaign.dart';

const mockCampaigns = [
  Campaign(
    id: 'cmp_001',
    title: 'School Kits for Rural Children',
    summary: 'Provide books and uniforms for 300 students.',
    description:
        'This campaign delivers school bags, notebooks, uniforms, and basic stationery for children in underserved rural communities.',
    organizationName: 'Hope Foundation',
    category: CampaignCategory.education,
    goalAmount: 12000,
    currentAmount: 7200,
    endDateIso: '2026-08-30',
    isActive: true,
    location: 'Amhara Region',
    donorCount: 148,
  ),
  Campaign(
    id: 'cmp_002',
    title: 'Mobile Clinic Outreach',
    summary: 'Fund recurring medical outreach in remote communities.',
    description:
        'Supports transportation, medicines, and volunteer logistics for monthly mobile clinic deployments.',
    organizationName: 'Care Outreach',
    category: CampaignCategory.health,
    goalAmount: 18000,
    currentAmount: 3100,
    endDateIso: '2026-09-15',
    isActive: true,
    location: 'Afar Region',
    donorCount: 62,
  ),
  Campaign(
    id: 'cmp_003',
    title: 'Emergency Food Support',
    summary: 'Distribute food packages to drought-affected families.',
    description:
        'Provides monthly nutrition packs with staple goods and supplementary foods for at-risk households.',
    organizationName: 'Relief Hands',
    category: CampaignCategory.emergency,
    goalAmount: 25000,
    currentAmount: 25000,
    endDateIso: '2026-05-01',
    isActive: false,
    location: 'Somali Region',
    donorCount: 514,
  ),
  Campaign(
    id: 'cmp_004',
    title: 'Community Green Spaces',
    summary: 'Restore community green zones and water points.',
    description:
        'Funds seedling nurseries, local labor, and irrigation tools for degraded public spaces.',
    organizationName: 'Green Tomorrow',
    category: CampaignCategory.environment,
    goalAmount: 15000,
    currentAmount: 4600,
    endDateIso: '2026-11-10',
    isActive: true,
    location: 'Addis Ababa',
    donorCount: 97,
  ),
];
