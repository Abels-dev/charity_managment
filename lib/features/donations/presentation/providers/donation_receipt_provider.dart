import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/models/donation_receipt.dart';

final donationReceiptProvider =
    FutureProvider.family<DonationReceipt?, String>((ref, donationId) async {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getReceiptByDonationId(donationId);
});
