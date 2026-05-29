import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/core/network/api_client.dart';
import 'package:charity_managment/features/donations/data/api_donation_repository.dart';
import 'package:charity_managment/repositories/donation_repository.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiDonationRepository(dio);
});
