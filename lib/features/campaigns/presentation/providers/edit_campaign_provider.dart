import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/domain/campaign_update_input.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaigns_list_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/my_campaigns_provider.dart';
import 'package:charity_managment/models/campaign.dart';

class EditCampaignController extends StateNotifier<AsyncValue<Campaign?>> {
  EditCampaignController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<Campaign?> update({
    required String campaignId,
    required String title,
    required String description,
    required String imageUrl,
    required double targetAmount,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(campaignRepositoryProvider);
      final campaign = await repository.updateCampaign(
        CampaignUpdateInput(
          campaignId: campaignId,
          title: title,
          description: description,
          imageUrl: imageUrl,
          targetAmount: targetAmount,
          endDate: endDate,
        ),
      );

      _ref.invalidate(myCampaignsProvider);
      _ref.invalidate(campaignsListProvider);
      _ref.invalidate(campaignDetailProvider(campaignId));
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

final editCampaignProvider =
    StateNotifierProvider<EditCampaignController, AsyncValue<Campaign?>>((ref) {
  return EditCampaignController(ref);
});
