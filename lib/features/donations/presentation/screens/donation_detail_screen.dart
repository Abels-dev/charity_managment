import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_detail_provider.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class DonationDetailScreen extends ConsumerWidget {
  const DonationDetailScreen({
    super.key,
    required this.donationId,
  });

  final String donationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationAsync = ref.watch(donationDetailProvider(donationId));

    return AppScaffold(
      title: 'Donation Detail',
      drawer: const AppNavigationDrawer(),
      body: donationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load donation',
          subtitle: error.toString(),
        ),
        data: (donation) {
          if (donation == null) {
            return const EmptyState(
              title: 'Donation not found',
              subtitle: 'This donation may have been removed.',
            );
          }

          return _DonationDetailBody(donation: donation);
        },
      ),
    );
  }
}

class _DonationDetailBody extends ConsumerWidget {
  const _DonationDetailBody({
    required this.donation,
  });

  final Donation donation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignAsync = ref.watch(campaignDetailProvider(donation.campaignId));
    final campaign = campaignAsync.valueOrNull;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          campaign?.title ?? 'Campaign ${donation.campaignId}',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        if (campaign != null)
          Text(
            'By ${campaign.organizationName}',
            style: theme.textTheme.bodyMedium,
          ),
        const SizedBox(height: 16),
        _DetailTile(
          label: 'Amount',
          value: CampaignFormatters.money(donation.amount),
        ),
        _DetailTile(
          label: 'Status',
          value: donation.status.label,
        ),
        _DetailTile(
          label: 'Transaction ID',
          value: donation.transactionId,
        ),
        _DetailTile(
          label: 'Donated at',
          value: CampaignFormatters.shortDate(donation.donatedAt),
        ),
        _DetailTile(
          label: 'Anonymous',
          value: donation.isAnonymous ? 'Yes' : 'No',
        ),
        if (donation.message != null && donation.message!.isNotEmpty)
          _DetailTile(
            label: 'Message',
            value: donation.message!,
          ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
