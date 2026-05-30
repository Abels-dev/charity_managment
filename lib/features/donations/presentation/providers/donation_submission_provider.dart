import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/donations/domain/donation_create_input.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_history_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/models/donation.dart';

class DonationSubmissionController extends StateNotifier<AsyncValue<Donation?>> {
  DonationSubmissionController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<Donation?> submit(DonationCreateInput input) async {
    if (input.amount <= 0) {
      state = AsyncValue.error('Donation amount must be greater than 0.', StackTrace.current);
      return null;
    }

    final user = _ref.read(authControllerProvider).user;
    final donorName = user?.fullName ?? input.donorName?.trim() ?? '';
    final donorEmail = user?.email ?? input.donorEmail?.trim() ?? '';

    if (user == null && (donorName.isEmpty || donorEmail.isEmpty)) {
      state = AsyncValue.error(
        'Guest name and email are required for unauthenticated donations.',
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(donationRepositoryProvider);
      final donation = Donation(
        id: 'dn_${DateTime.now().millisecondsSinceEpoch}',
        donorId: input.donorId ?? user?.id ?? '',
        campaignId: input.campaignId,
        amount: input.amount,
        isAnonymous: input.isAnonymous,
        message: input.message?.trim().isEmpty ?? true ? null : input.message?.trim(),
        transactionId: 'sim_${DateTime.now().millisecondsSinceEpoch}',
        status: DonationStatus.pending,
        donatedAt: DateTime.now(),
        guestName: user == null ? donorName : null,
        guestEmail: user == null ? donorEmail : null,
      );

      final completedDonation = await repository.createDirectDonation(
        donation,
        donorName: donorName,
        donorEmail: donorEmail,
      );

      _ref.invalidate(campaignDetailProvider(input.campaignId));
      _ref.invalidate(donationHistoryProvider);

      state = AsyncValue.data(completedDonation);
      return completedDonation;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final donationSubmissionProvider =
    StateNotifierProvider.autoDispose<DonationSubmissionController, AsyncValue<Donation?>>((ref) {
  return DonationSubmissionController(ref);
});
