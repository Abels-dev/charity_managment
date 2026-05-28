import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/donor_dashboard/presentation/providers/donor_dashboard_providers.dart';
import 'package:charity_managment/features/donor_dashboard/domain/donor_dashboard_summary.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/widgets/donation_card.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class DonorDashboardScreen extends ConsumerWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(donorDashboardSummaryProvider);
    final recentAsync = ref.watch(donorRecentDonationsProvider);
    final followedAsync = ref.watch(donorFollowedPreviewProvider);

    return AppScaffold(
      title: 'Donor Dashboard',
      drawer: const AppNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(donorDashboardSummaryProvider);
          ref.invalidate(donorRecentDonationsProvider);
          ref.invalidate(donorFollowedPreviewProvider);
          await Future.wait([
            ref.read(donorDashboardSummaryProvider.future),
            ref.read(donorRecentDonationsProvider.future),
            ref.read(donorFollowedPreviewProvider.future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _QuickActionsRow(
              onBrowse: () => context.go(AppRoutes.campaigns),
              onDonations: () => context.go(AppRoutes.donations),
              onAnonymous: () => context.go(AppRoutes.anonymousDonations),
              onFollowing: () => context.go(AppRoutes.followedCampaigns),
            ),
            const SizedBox(height: 16),
            const _SectionHeader(
              title: 'Overview',
              subtitle: 'Track your giving impact in one place.',
            ),
            const SizedBox(height: 12),
            summaryAsync.when(
              loading: () => const _SectionLoading(height: 160),
              error: (error, _) => _SectionError(
                title: 'Unable to load donor summary',
                message: error.toString(),
                onRetry: () => ref.invalidate(donorDashboardSummaryProvider),
              ),
              data: (summary) => _SummaryGrid(summary: summary),
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Recent donations',
              subtitle: 'Your latest contributions.',
              trailing: TextButton(
                onPressed: () => context.go(AppRoutes.donations),
                child: const Text('View all'),
              ),
            ),
            const SizedBox(height: 12),
            recentAsync.when(
              loading: () => const _SectionLoading(height: 140),
              error: (error, _) => _SectionError(
                title: 'Unable to load donations',
                message: error.toString(),
                onRetry: () => ref.invalidate(donorRecentDonationsProvider),
              ),
              data: (donations) {
                if (donations.isEmpty) {
                  return const EmptyState(
                    title: 'No donations yet',
                    subtitle: 'Support a campaign to see it here.',
                  );
                }

                return Column(
                  children: [
                    for (final donation in donations) ...[
                      _DonationCardTile(donationId: donation.id),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Followed campaigns',
              subtitle: 'Campaigns you are tracking.',
              trailing: TextButton(
                onPressed: () => context.go(AppRoutes.followedCampaigns),
                child: const Text('View all'),
              ),
            ),
            const SizedBox(height: 12),
            followedAsync.when(
              loading: () => const _SectionLoading(height: 140),
              error: (error, _) => _SectionError(
                title: 'Unable to load followed campaigns',
                message: error.toString(),
                onRetry: () => ref.invalidate(donorFollowedPreviewProvider),
              ),
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return const EmptyState(
                    title: 'Not following any campaigns',
                    subtitle: 'Tap follow on a campaign to track it here.',
                  );
                }

                return Column(
                  children: [
                    for (final campaign in campaigns) ...[
                      CampaignCard(
                        campaign: campaign,
                        isFollowed: true,
                        onTap: () => context.go(
                          AppRoutes.campaignDetail(campaign.id),
                        ),
                        onFollowTap: () {},
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.onBrowse,
    required this.onDonations,
    required this.onAnonymous,
    required this.onFollowing,
  });

  final VoidCallback onBrowse;
  final VoidCallback onDonations;
  final VoidCallback onAnonymous;
  final VoidCallback onFollowing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onBrowse,
          icon: const Icon(Icons.search),
          label: const Text('Browse'),
        ),
        OutlinedButton.icon(
          onPressed: onDonations,
          icon: const Icon(Icons.payments_outlined),
          label: const Text('Donations'),
        ),
        OutlinedButton.icon(
          onPressed: onAnonymous,
          icon: const Icon(Icons.visibility_off_outlined),
          label: const Text('Anonymous'),
        ),
        OutlinedButton.icon(
          onPressed: onFollowing,
          icon: const Icon(Icons.favorite_border),
          label: const Text('Following'),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final DonorDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tiles = [
      _StatCard(
        title: 'Total donated',
        value: summary.totalDonated.toStringAsFixed(0),
        icon: Icons.savings_outlined,
        color: colorScheme.primary,
      ),
      _StatCard(
        title: 'Campaigns supported',
        value: summary.campaignsSupported.toString(),
        icon: Icons.campaign_outlined,
        color: colorScheme.tertiary,
      ),
      _StatCard(
        title: 'Monthly total',
        value: summary.monthlyTotal.toStringAsFixed(0),
        icon: Icons.calendar_month,
        color: colorScheme.secondary,
      ),
      _StatCard(
        title: 'Following',
        value: summary.activeFollowed.toString(),
        icon: Icons.favorite,
        color: colorScheme.error,
      ),
      _StatCard(
        title: 'Anonymous',
        value: summary.anonymousCount.toString(),
        icon: Icons.visibility_off_outlined,
        color: colorScheme.outline,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tiles
          .map(
            (tile) => SizedBox(
              width: 160,
              child: tile,
            ),
          )
          .toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DonationCardTile extends ConsumerWidget {
  const _DonationCardTile({required this.donationId});

  final String donationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationAsync = ref.watch(donationDetailProvider(donationId));

    return donationAsync.when(
      loading: () => const _SectionLoading(height: 96),
      error: (error, _) => EmptyState(
        title: 'Unable to load donation',
        subtitle: error.toString(),
      ),
      data: (donation) {
        if (donation == null) {
          return const EmptyState(
            title: 'Donation not found',
            subtitle: 'This donation is no longer available.',
          );
        }

        final campaignAsync = ref.watch(campaignDetailProvider(donation.campaignId));
        final title = campaignAsync.valueOrNull?.title ?? 'Campaign ${donation.campaignId}';

        return DonationCard(
          donation: donation,
          campaignTitle: title,
          onTap: () => context.go(AppRoutes.donationReceipt(donation.id)),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmptyState(title: title, subtitle: message),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
