import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_create_input.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaigns_list_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/my_campaigns_provider.dart';
import 'package:charity_managment/models/campaign.dart';

class CreateCampaignController extends StateNotifier<AsyncValue<Campaign?>> {
  CreateCampaignController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<Campaign?> create({
    required String title,
    required String description,
    required String imageUrl,
    required double targetAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = _ref.read(authControllerProvider).user;
    if (user == null) {
      state = AsyncValue.error('You must be signed in.', StackTrace.current);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(campaignRepositoryProvider);
      final campaign = await repository.createCampaign(
        CampaignCreateInput(
          charityId: user.id,
          charityName: user.fullName,
          title: title,
          description: description,
          imageUrl: imageUrl,
          targetAmount: targetAmount,
          startDate: startDate,
          endDate: endDate,
        ),
      );

      _ref.invalidate(myCampaignsProvider);
      _ref.invalidate(campaignsListProvider);
      state = AsyncValue.data(campaign);
      return campaign;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final createCampaignProvider =
    StateNotifierProvider<CreateCampaignController, AsyncValue<Campaign?>>((ref) {
  return CreateCampaignController(ref);
});
