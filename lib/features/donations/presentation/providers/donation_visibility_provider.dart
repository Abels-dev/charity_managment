import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';

class DonationVisibilityController extends StateNotifier<AsyncValue<void>> {
  DonationVisibilityController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> setAnonymous({
    required String donationId,
    required bool isAnonymous,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(donationRepositoryProvider);
      await repository.setDonationAnonymous(
        donationId: donationId,
        isAnonymous: isAnonymous,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final donationVisibilityProvider =
    StateNotifierProvider<DonationVisibilityController, AsyncValue<void>>((ref) {
  return DonationVisibilityController(ref);
});
