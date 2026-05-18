import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/widgets/donation_success_card.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class DonationSuccessScreen extends ConsumerWidget {
  const DonationSuccessScreen({
    super.key,
    required this.donationId,
  });

  final String donationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationAsync = ref.watch(donationDetailProvider(donationId));

    return AppScaffold(
      title: 'Donation Success',
      drawer: const AppNavigationDrawer(),
      showNotificationAction: false,
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

          final campaignAsync = ref.watch(campaignDetailProvider(donation.campaignId));
          final campaignTitle =
              campaignAsync.valueOrNull?.title ?? 'Campaign ${donation.campaignId}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DonationSuccessCard(donation: donation),
              const SizedBox(height: 16),
              Text(
                campaignTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.go(AppRoutes.donationReceipt(donation.id)),
                      child: const Text('View Receipt'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          context.go(AppRoutes.campaignDetail(donation.campaignId)),
                      child: const Text('Back to Campaign'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
