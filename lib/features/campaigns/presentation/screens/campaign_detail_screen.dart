import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class CampaignDetailScreen extends ConsumerWidget {
  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(campaignDetailProvider(campaignId));

    return AppScaffold(
      title: 'Campaign Detail',
      drawer: const AppNavigationDrawer(),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load campaign',
          subtitle: error.toString(),
        ),
        data: (campaign) {
          if (campaign == null) {
            return const EmptyState(
              title: 'Campaign not found',
              subtitle: 'This campaign may have been removed.',
            );
          }

          final isFollowed = ref.watch(isCampaignFollowedProvider(campaign.id));
          final followController = ref.read(campaignFollowProvider.notifier);

          return ListView(
            children: [
              Text(
                campaign.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('By ${campaign.organizationName}'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(campaign.category.label),
                  const SizedBox(width: 8),
                  CampaignStatusBadge(status: campaign.status),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: campaign.progress),
              const SizedBox(height: 10),
              Text(
                '${CampaignFormatters.percent(campaign.progress)} funded',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '${CampaignFormatters.money(campaign.currentAmount)} raised of ${CampaignFormatters.money(campaign.goalAmount)} goal',
              ),
              const SizedBox(height: 4),
              Text('Remaining: ${CampaignFormatters.money(campaign.remainingAmount)}'),
              const SizedBox(height: 16),
              Text(
                campaign.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _MetaRow(label: 'Location', value: campaign.location ?? 'N/A'),
              _MetaRow(label: 'Start date', value: CampaignFormatters.shortDate(campaign.startDate)),
              _MetaRow(label: 'End date', value: CampaignFormatters.shortDate(campaign.endDate)),
              _MetaRow(label: 'Donors', value: '${campaign.donorCount}'),
              _MetaRow(label: 'Status', value: campaign.status.label),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: campaign.status == CampaignStatus.closed
                    ? null
                    : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donation flow will be added soon.')),
                  );
                },
                child: const Text('Donate'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => followController.toggleFollow(campaign.id),
                icon: Icon(isFollowed ? Icons.favorite : Icons.favorite_border),
                label: Text(isFollowed ? 'Following Campaign' : 'Follow Campaign'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
