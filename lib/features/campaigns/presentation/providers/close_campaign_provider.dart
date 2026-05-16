import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaigns_list_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/my_campaigns_provider.dart';

class CloseCampaignController extends StateNotifier<AsyncValue<Set<String>>> {
  CloseCampaignController(this._ref) : super(const AsyncValue.data(<String>{}));

  final Ref _ref;

  Future<void> closeCampaign(String campaignId) async {
    final current = state.valueOrNull ?? <String>{};
    state = AsyncValue.data({...current, campaignId});

    try {
      final repository = _ref.read(campaignRepositoryProvider);
      await repository.closeCampaign(campaignId);

      _ref.invalidate(myCampaignsProvider);
      _ref.invalidate(campaignsListProvider);
      _ref.invalidate(campaignDetailProvider(campaignId));
      state = AsyncValue.data({...current}..remove(campaignId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      state = AsyncValue.data(current);
    }
  }

  bool isClosing(String campaignId) {
    return state.valueOrNull?.contains(campaignId) ?? false;
  }
}

final closeCampaignProvider =
    StateNotifierProvider<CloseCampaignController, AsyncValue<Set<String>>>((ref) {
  return CloseCampaignController(ref);
});
