import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_history_provider.dart';
import 'package:charity_managment/features/donations/presentation/widgets/donation_card.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class DonationsScreen extends ConsumerWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(donationHistoryProvider);

    return AppScaffold(
      title: 'Donations',
      drawer: const AppNavigationDrawer(),
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load donations',
          subtitle: error.toString(),
        ),
        data: (donations) {
          if (donations.isEmpty) {
            return const EmptyState(
              title: 'No donations yet',
              subtitle: 'Support a campaign to see your donation history here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: donations.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final donation = donations[index];
              return _DonationCardTile(donation: donation);
            },
          );
        },
      ),
    );
  }
}

class _DonationCardTile extends ConsumerWidget {
  const _DonationCardTile({
    required this.donation,
  });

  final Donation donation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignAsync = ref.watch(campaignDetailProvider(donation.campaignId));
    final title = campaignAsync.valueOrNull?.title ?? 'Campaign ${donation.campaignId}';

    return DonationCard(
      donation: donation,
      campaignTitle: title,
      onTap: () => context.go(AppRoutes.donationReceipt(donation.id)),
    );
  }
}
