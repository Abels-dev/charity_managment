import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/charities/presentation/providers/charity_public_profile_provider.dart';
import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class CharityPublicProfileScreen extends ConsumerWidget {
  const CharityPublicProfileScreen({
    super.key,
    required this.charityId,
  });

  final String charityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profileAsync = ref.watch(charityPublicProfileProvider(charityId));
    final followController = ref.read(campaignFollowProvider.notifier);
    final followedIds = ref.watch(campaignFollowProvider).valueOrNull ?? <String>{};

    return AppScaffold(
      title: 'Charity Profile',
      drawer: const AppNavigationDrawer(),
      showNotificationAction: auth.isAuthenticated,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load charity profile',
          subtitle: error.toString(),
        ),
        data: (details) {
          if (details == null) {
            return const EmptyState(
              title: 'Charity not found',
              subtitle: 'This charity profile is no longer available.',
            );
          }

          final profile = details.profile;
          final stats = details.stats;
          final campaigns = details.campaigns;

          return ListView(
            children: [
              _HeaderCard(profile: profile),
              const SizedBox(height: 16),
              _StatsRow(stats: stats),
              const SizedBox(height: 20),
              Text('Active campaigns', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (campaigns.isEmpty)
                const EmptyState(
                  title: 'No campaigns yet',
                  subtitle: 'This charity has not published any campaigns yet.',
                )
              else
                Column(
                  children: [
                    for (final campaign in campaigns) ...[
                      CampaignCard(
                        campaign: campaign,
                        isFollowed: followedIds.contains(campaign.id),
                        onTap: () => context.go(
                          AppRoutes.campaignDetail(campaign.id),
                        ),
                        onFollowTap: () => _handleFollowTap(
                          context,
                          auth.isAuthenticated,
                          followController,
                          campaign.id,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleFollowTap(
    BuildContext context,
    bool isAuthenticated,
    CampaignFollowController controller,
    String campaignId,
  ) {
    if (!isAuthenticated) {
      _promptSignIn(context);
      return;
    }
    controller.toggleFollow(campaignId);
  }

  void _promptSignIn(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sign in to follow campaigns.'),
        action: SnackBarAction(
          label: 'Sign in',
          onPressed: () => context.go(AppRoutes.roleSelection),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final CharityPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.favorite, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.organizationName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (profile.isVerified)
                        Text(
                          'Verified charity',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: colorScheme.primary),
                        )
                      else
                        Text(
                          'Verification pending',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: colorScheme.tertiary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.description != null)
              Text(
                profile.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (profile.description != null) const SizedBox(height: 12),
            _InfoRow(label: 'Phone', value: profile.phone ?? 'Not provided'),
            _InfoRow(label: 'Website', value: profile.website ?? 'Not provided'),
            _InfoRow(label: 'Address', value: profile.address ?? 'Not provided'),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final CharityStats stats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatTile(
          label: 'Campaigns',
          value: stats.totalCampaigns.toString(),
          textTheme: textTheme,
        ),
        _StatTile(
          label: 'Active',
          value: stats.activeCampaigns.toString(),
          textTheme: textTheme,
        ),
        _StatTile(
          label: 'Raised',
          value: stats.totalRaised.toStringAsFixed(0),
          textTheme: textTheme,
        ),
        _StatTile(
          label: 'Donors',
          value: stats.totalDonors.toString(),
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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
