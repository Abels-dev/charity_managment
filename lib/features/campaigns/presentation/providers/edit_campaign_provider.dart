import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/domain/campaign_update_input.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaigns_list_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/my_campaigns_provider.dart';
import 'package:charity_managment/features/notifications/data/notification_followers_registry.dart';
import 'package:charity_managment/features/notifications/domain/notification_factory.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_repository_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_unread_count_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notifications_list_provider.dart';
import 'package:charity_managment/models/campaign.dart';

class EditCampaignController extends StateNotifier<AsyncValue<Campaign?>> {
  EditCampaignController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<Campaign?> update({
    required String campaignId,
    required String title,
    required String description,
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
          targetAmount: targetAmount,
          endDate: endDate,
        ),
      );

      _ref.invalidate(myCampaignsProvider);
      _ref.invalidate(campaignsListProvider);
      _ref.invalidate(campaignDetailProvider(campaignId));

      final followers = NotificationFollowersRegistry.followersForCampaign(campaignId);
      if (followers.isNotEmpty) {
        final notificationRepository = _ref.read(notificationRepositoryProvider);
        for (final followerId in followers) {
          await notificationRepository.createNotification(
            NotificationFactory.campaignUpdated(
              userId: followerId,
              campaign: campaign,
            ),
          );
        }
        _ref.invalidate(notificationsListProvider);
        _ref.invalidate(notificationUnreadCountProvider);
      }

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
