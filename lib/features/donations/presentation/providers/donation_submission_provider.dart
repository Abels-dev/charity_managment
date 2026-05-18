import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaigns_list_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/followed_campaigns_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
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
        status: DonationStatus.completed,
        donatedAt: DateTime.now(),
      );

      final created = await repository.createDonation(donation);
      final campaignRepository = _ref.read(campaignRepositoryProvider);
      await campaignRepository.applyDonation(
        campaignId: input.campaignId,
        amount: input.amount,
      );

      _ref.invalidate(donationHistoryProvider);
      _ref.invalidate(campaignsListProvider);
      _ref.invalidate(followedCampaignsProvider);
      _ref.invalidate(campaignDetailProvider(input.campaignId));
      state = AsyncValue.data(created);
      return created;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
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

final donationSubmissionProvider =
    StateNotifierProvider.autoDispose<DonationSubmissionController, AsyncValue<Donation?>>((ref) {
  return DonationSubmissionController(ref);
});
