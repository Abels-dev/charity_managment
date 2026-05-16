import 'package:charity_managment/models/donation.dart';

const mockDonations = [
  Donation(
    id: 'dn_001',
    campaignId: 'cmp_001',
    donorId: 'u_donor_01',
    amount: 50,
    currency: 'USD',
    donatedAtIso: '2026-05-12T09:30:00Z',
    message: 'Happy to support this cause.',
  ),
  Donation(
    id: 'dn_002',
    campaignId: 'cmp_002',
    donorId: 'u_donor_01',
    amount: 20,
    currency: 'USD',
    donatedAtIso: '2026-05-13T12:15:00Z',
  ),
];
