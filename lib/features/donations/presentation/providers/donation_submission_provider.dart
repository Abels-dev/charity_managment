import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/donations/domain/donation_checkout_session.dart';
import 'package:charity_managment/features/donations/domain/donation_create_input.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/routing/app_routes.dart';

class DonationSubmissionController
    extends StateNotifier<AsyncValue<DonationCheckoutSession?>> {
  DonationSubmissionController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<DonationCheckoutSession?> submit(DonationCreateInput input) async {
    if (input.amount < 10) {
      state = AsyncValue.error(
        'Minimum donation is 10 ETB.',
        StackTrace.current,
      );
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
        message:
            input.message?.trim().isEmpty ?? true ? null : input.message?.trim(),
        transactionId: 'checkout_${DateTime.now().millisecondsSinceEpoch}',
        status: DonationStatus.pending,
        donatedAt: DateTime.now(),
        guestName: user == null ? donorName : null,
        guestEmail: user == null ? donorEmail : null,
      );

      final checkoutSession = await repository.createDonationCheckout(
        donation,
        donorName: donorName,
        donorEmail: donorEmail,
        returnUrl: AppRoutes.mobileChapaReturnUrl,
      );

      if (checkoutSession.checkoutUrl.isEmpty || checkoutSession.txRef.isEmpty) {
        throw StateError('Payment checkout could not be initialized.');
      }

      state = AsyncValue.data(checkoutSession);
      return checkoutSession;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final donationSubmissionProvider = StateNotifierProvider.autoDispose<
    DonationSubmissionController, AsyncValue<DonationCheckoutSession?>>((ref) {
  return DonationSubmissionController(ref);
});
