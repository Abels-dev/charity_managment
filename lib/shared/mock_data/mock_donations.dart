import 'package:charity_managment/models/donation.dart';

final mockDonations = [
  Donation(
    id: 'dn_001',
    donorId: 'user_12345',
    campaignId: 'cmp_001',
    amount: 50,
    isAnonymous: false,
    message: 'Happy to support this cause.',
    transactionId: 'txn_001',
    status: DonationStatus.completed,
    donatedAt: DateTime(2026, 5, 12, 9, 30),
  ),
  Donation(
    id: 'dn_002',
    donorId: 'user_12345',
    campaignId: 'cmp_002',
    amount: 20,
    isAnonymous: true,
    transactionId: 'txn_002',
    status: DonationStatus.completed,
    donatedAt: DateTime(2026, 5, 13, 12, 15),
  ),
];
