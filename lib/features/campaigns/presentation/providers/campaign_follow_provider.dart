import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/followed_campaigns_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';

class CampaignFollowController extends StateNotifier<AsyncValue<Set<String>>> {
  CampaignFollowController(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    try {
      final repository = _ref.read(campaignRepositoryProvider);
      final ids = await repository.getFollowedCampaignIds();
      state = AsyncValue.data(ids);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleFollow(String campaignId) async {
    final repository = _ref.read(campaignRepositoryProvider);
    final current = state.valueOrNull ?? <String>{};
    final shouldFollow = !current.contains(campaignId);

    final next = <String>{...current};
    if (shouldFollow) {
      next.add(campaignId);
    } else {
      next.remove(campaignId);
    }

    state = AsyncValue.data(next);

    try {
      await repository.setCampaignFollowed(
        campaignId: campaignId,
        followed: shouldFollow,
      );
      _ref.invalidate(followedCampaignsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      state = AsyncValue.data(current);
    }
  }
}

final campaignFollowProvider =
    StateNotifierProvider<CampaignFollowController, AsyncValue<Set<String>>>((ref) {
  return CampaignFollowController(ref);
});

final isCampaignFollowedProvider = Provider.family<bool, String>((ref, campaignId) {
  final followed = ref.watch(campaignFollowProvider);
  return followed.valueOrNull?.contains(campaignId) ?? false;
});
