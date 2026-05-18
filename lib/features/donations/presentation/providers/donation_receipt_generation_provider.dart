import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/donations/presentation/providers/donation_receipt_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/donation_receipt.dart';

class DonationReceiptController extends StateNotifier<AsyncValue<DonationReceipt?>> {
  DonationReceiptController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<DonationReceipt?> generate(Donation donation) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(donationRepositoryProvider);
      final receipt = await repository.generateReceipt(donation);
      _ref.invalidate(donationReceiptProvider(donation.id));
      state = AsyncValue.data(receipt);
      return receipt;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final donationReceiptGenerationProvider =
    StateNotifierProvider<DonationReceiptController, AsyncValue<DonationReceipt?>>((ref) {
  return DonationReceiptController(ref);
});
