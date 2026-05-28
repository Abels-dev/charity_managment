import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/features/public_home/presentation/providers/featured_campaigns_provider.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class PublicHomeScreen extends ConsumerWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final featuredAsync = ref.watch(featuredCampaignsProvider);
    final followController = ref.read(campaignFollowProvider.notifier);
    final followedIds = ref.watch(campaignFollowProvider).valueOrNull ?? <String>{};

    return AppScaffold(
      title: 'Charity Management',
      drawer: const AppNavigationDrawer(),
      showNotificationAction: auth.isAuthenticated,
      body: ListView(
        children: [
          _HeroSection(isAuthenticated: auth.isAuthenticated),
          const SizedBox(height: 20),
          const _SectionHeader(
            title: 'Featured campaigns',
            subtitle: 'Explore causes making a real impact today.',
          ),
          const SizedBox(height: 12),
          featuredAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              title: 'Unable to load campaigns',
              subtitle: error.toString(),
            ),
            data: (campaigns) {
              if (campaigns.isEmpty) {
                return const EmptyState(
                  title: 'No featured campaigns yet',
                  subtitle: 'Check back soon for new opportunities to give.',
                );
              }

              return Column(
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
              );
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.go(AppRoutes.campaigns),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Browse all campaigns'),
            ),
          ),
        ],
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Make every contribution count.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Discover trusted campaigns, track impact, and support charities you care about.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.campaigns),
                  icon: const Icon(Icons.search),
                  label: const Text('Explore campaigns'),
                ),
                if (!isAuthenticated)
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.roleSelection),
                    icon: const Icon(Icons.login),
                    label: const Text('Get started'),
                  ),
                if (!isAuthenticated)
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Sign in'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
