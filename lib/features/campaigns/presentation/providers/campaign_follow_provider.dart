import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/followed_campaigns_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/features/notifications/data/notification_followers_registry.dart';

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

      final user = _ref.read(authControllerProvider).user;
      if (user != null) {
        for (final campaignId in ids) {
          final campaign = await repository.getCampaignById(campaignId);
          if (campaign != null) {
            NotificationFollowersRegistry.followCampaign(
              userId: user.id,
              campaignId: campaignId,
              charityId: campaign.charityId,
            );
          }
        }
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleFollow(String campaignId) async {
    final repository = _ref.read(campaignRepositoryProvider);
    final user = _ref.read(authControllerProvider).user;
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
      final campaign = await repository.getCampaignById(campaignId);
      if (user != null && campaign != null) {
        if (shouldFollow) {
          NotificationFollowersRegistry.followCampaign(
            userId: user.id,
            campaignId: campaignId,
            charityId: campaign.charityId,
          );
        } else {
          NotificationFollowersRegistry.unfollowCampaign(
            userId: user.id,
            campaignId: campaignId,
            charityId: campaign.charityId,
          );
        }
      }
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
