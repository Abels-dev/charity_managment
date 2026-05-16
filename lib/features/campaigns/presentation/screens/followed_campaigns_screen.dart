import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/followed_campaigns_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class FollowedCampaignsScreen extends ConsumerWidget {
  const FollowedCampaignsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(followedCampaignsProvider);
    await ref.read(followedCampaignsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedAsync = ref.watch(followedCampaignsProvider);
    final followedIds = ref.watch(campaignFollowProvider).valueOrNull ?? <String>{};
    final followController = ref.read(campaignFollowProvider.notifier);

    return AppScaffold(
      title: 'Followed Campaigns',
      drawer: const AppNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: followedAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              EmptyState(
                title: 'Unable to load followed campaigns',
                subtitle: error.toString(),
              ),
            ],
          ),
          data: (campaigns) {
            if (campaigns.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  EmptyState(
                    title: 'No followed campaigns',
                    subtitle: 'Follow a campaign to track it here.',
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: campaigns.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final campaign = campaigns[index];
                final isFollowed = followedIds.contains(campaign.id);

                return CampaignCard(
                  campaign: campaign,
                  isFollowed: isFollowed,
                  onTap: () => context.go(AppRoutes.campaignDetail(campaign.id)),
                  onFollowTap: () => followController.toggleFollow(campaign.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
