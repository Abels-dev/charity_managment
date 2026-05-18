import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/donations/data/mock_donation_repository.dart';
import 'package:charity_managment/repositories/donation_repository.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return MockDonationRepository();
});
