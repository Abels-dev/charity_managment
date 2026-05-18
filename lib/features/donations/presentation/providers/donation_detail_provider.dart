import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/models/donation.dart';

final donationDetailProvider = FutureProvider.family<Donation?, String>((ref, donationId) async {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getDonationById(donationId);
});
