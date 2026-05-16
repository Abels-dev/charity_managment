import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/close_campaign_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/my_campaigns_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/my_campaign_card.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class MyCampaignsScreen extends ConsumerWidget {
  const MyCampaignsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myCampaignsProvider);
    await ref.read(myCampaignsProvider.future);
  }

  Future<void> _confirmCloseCampaign(
    BuildContext context,
    WidgetRef ref,
    String campaignId,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Close Campaign'),
          content: const Text(
            'Are you sure you want to close this campaign? This action will disable further donations and editing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Close Campaign'),
            ),
          ],
        );
      },
    );

    if (result != true || !context.mounted) return;
    await ref.read(closeCampaignProvider.notifier).closeCampaign(campaignId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myCampaignsAsync = ref.watch(myCampaignsProvider);
    final closingIds = ref.watch(closeCampaignProvider).valueOrNull ?? <String>{};

    return AppScaffold(
      title: 'My Campaigns',
      drawer: const AppNavigationDrawer(),
      actions: [
        IconButton(
          tooltip: 'Create campaign',
          onPressed: () => context.go(AppRoutes.createCampaign),
          icon: const Icon(Icons.add),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: myCampaignsAsync.when(
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
                title: 'Unable to load your campaigns',
                subtitle: error.toString(),
              ),
            ],
          ),
          data: (campaigns) {
            if (campaigns.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const EmptyState(
                    title: 'No campaigns yet',
                    subtitle: 'Create your first campaign to start raising support.',
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: FilledButton(
                      onPressed: () => context.go(AppRoutes.createCampaign),
                      child: const Text('Create Campaign'),
                    ),
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
                return MyCampaignCard(
                  campaign: campaign,
                  isClosing: closingIds.contains(campaign.id),
                  onView: () => context.go(AppRoutes.campaignDetail(campaign.id)),
                  onEdit: () => context.go(AppRoutes.editCampaign(campaign.id)),
                  onClose: () => _confirmCloseCampaign(
                    context,
                    ref,
                    campaign.id,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
