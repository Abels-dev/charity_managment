import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/donations/domain/donation_create_input.dart';
import 'package:charity_managment/features/donations/domain/donation_checkout_session.dart';
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
    if (user == null) {
      state = AsyncValue.error('You must be signed in to donate.', StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(donationRepositoryProvider);
      final donation = Donation(
        id: _nextDonationId(),
        donorId: input.donorId,
        campaignId: input.campaignId,
        amount: input.amount,
        isAnonymous: input.isAnonymous,
        message: input.message?.trim().isEmpty ?? true ? null : input.message?.trim(),
        transactionId: _nextTransactionId(),
        status: DonationStatus.pending,
        donatedAt: DateTime.now(),
      );

      final session = await repository.createDonationCheckout(
        donation,
        donorName: _ref.read(authControllerProvider).user?.fullName,
        donorEmail: _ref.read(authControllerProvider).user?.email,
      );

      developer.log('Donation checkout session received', name: 'donation', error: {
        'actionUrl': session.actionUrl,
        'txRef': session.txRef,
        'fieldsCount': session.fields.length,
      });

      _ref.read(donationCheckoutSessionProvider.notifier).state = session;

      final pendingDonation = Donation(
        id: donation.id,
        donorId: donation.donorId,
        campaignId: donation.campaignId,
        amount: donation.amount,
        isAnonymous: donation.isAnonymous,
        transactionId: session.txRef.isNotEmpty ? session.txRef : donation.transactionId,
        status: DonationStatus.pending,
        donatedAt: donation.donatedAt,
        message: donation.message,
      );

      state = AsyncValue.data(pendingDonation);
      return pendingDonation;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<Donation?> refreshCheckoutStatus() async {
    final session = _ref.read(donationCheckoutSessionProvider);
    if (session == null || session.txRef.isEmpty) {
      state = AsyncValue.error('No active checkout session found.', StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(donationRepositoryProvider);
      final donation = await repository.getDonationByTransactionRef(session.txRef);

      if (donation == null) {
        state = AsyncValue.error('Payment not found yet. Please try again.', StackTrace.current);
        return null;
      }

      state = AsyncValue.data(donation);

      if (donation.status == DonationStatus.completed ||
          donation.status == DonationStatus.failed ||
          donation.status == DonationStatus.refunded) {
        _ref.read(donationCheckoutSessionProvider.notifier).state = null;
      }

      _ref.invalidate(donationHistoryProvider);
      return donation;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
    _ref.read(donationCheckoutSessionProvider.notifier).state = null;
  }

  String _nextDonationId() {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'dn_$stamp';
  }

  String _nextTransactionId() {
    final rand = Random().nextInt(999999);
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_$rand';
  }
}

final donationCheckoutSessionProvider = StateProvider<DonationCheckoutSession?>((ref) => null);

final donationSubmissionProvider =
    StateNotifierProvider.autoDispose<DonationSubmissionController, AsyncValue<Donation?>>((ref) {
  return DonationSubmissionController(ref);
});
