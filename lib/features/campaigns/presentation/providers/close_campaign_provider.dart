import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaigns_list_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/my_campaigns_provider.dart';
import 'package:charity_managment/features/notifications/data/notification_followers_registry.dart';
import 'package:charity_managment/features/notifications/domain/notification_factory.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_repository_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_unread_count_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notifications_list_provider.dart';

class CloseCampaignController extends StateNotifier<AsyncValue<Set<String>>> {
  CloseCampaignController(this._ref) : super(const AsyncValue.data(<String>{}));

  final Ref _ref;

  Future<void> closeCampaign(String campaignId) async {
    final current = state.valueOrNull ?? <String>{};
    state = AsyncValue.data({...current, campaignId});

    try {
      final repository = _ref.read(campaignRepositoryProvider);
      final campaign = await repository.closeCampaign(campaignId);

      _ref.invalidate(myCampaignsProvider);
      _ref.invalidate(campaignsListProvider);
      _ref.invalidate(campaignDetailProvider(campaignId));

      final followers = NotificationFollowersRegistry.followersForCampaign(campaignId);
      if (followers.isNotEmpty) {
        final notificationRepository = _ref.read(notificationRepositoryProvider);
        for (final followerId in followers) {
          await notificationRepository.createNotification(
            NotificationFactory.campaignClosed(
              userId: followerId,
              campaign: campaign,
            ),
          );
        }
        _ref.invalidate(notificationsListProvider);
        _ref.invalidate(notificationUnreadCountProvider);
      }

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
