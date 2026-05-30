import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/donor_dashboard/presentation/providers/donor_dashboard_providers.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/widgets/donation_card.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

import 'package:charity_managment/core/widgets/empty_state.dart';
import 'package:charity_managment/core/widgets/loading_skeleton.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';

class DonorDashboardScreen extends ConsumerWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final summaryAsync = ref.watch(donorDashboardSummaryProvider);
    final recentAsync = ref.watch(donorRecentDonationsProvider);
    final followedAsync = ref.watch(donorFollowedPreviewProvider);

    return AppScaffold(
      title: 'Dashboard',
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
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryBg,
                    child: Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                      style: AppTextStyles.title.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          user?.fullName ?? 'Donor',
                          style: AppTextStyles.display.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing32),
            
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: _SectionLoading(height: 120),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Unable to load summary',
                  message: error.toString(),
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(donorDashboardSummaryProvider),
                ),
              ),
              data: (summary) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Donated',
                        value: 'ETB ${summary.totalDonated.toStringAsFixed(0)}',
                        icon: Icons.savings_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: _StatCard(
                        title: 'Campaigns',
                        value: summary.campaignsSupported.toString(),
                        icon: Icons.favorite_border,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: _QuickActionsRow(
                onBrowse: () => context.go(AppRoutes.campaigns),
                onDonations: () => context.go(AppRoutes.donations),
                onAnonymous: () => context.go(AppRoutes.anonymoETBonations),
                onFollowing: () => context.go(AppRoutes.followedCampaigns),
              ),
            ),

            const SizedBox(height: AppTheme.spacing32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: _SectionHeader(
                title: 'Recent donations',
                subtitle: 'Your latest contributions.',
                onViewAll: () => context.go(AppRoutes.donations),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            recentAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: _SectionLoading(height: 140),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Unable to load donations',
                  message: error.toString(),
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(donorRecentDonationsProvider),
                ),
              ),
              data: (donations) {
                if (donations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No donations yet',
                      message: 'Support a campaign to see it here.',
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                  itemCount: donations.length,
                  separatorBuilder: (_, index) => const SizedBox(height: AppTheme.spacing12),
                  itemBuilder: (_, index) => _DonationCardTile(donationId: donations[index].id),
                );
              },
            ),
            
            const SizedBox(height: AppTheme.spacing32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: _SectionHeader(
                title: 'Followed campaigns',
                subtitle: 'Campaigns you are tracking.',
                onViewAll: () => context.go(AppRoutes.followedCampaigns),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            followedAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: _SectionLoading(height: 140),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Unable to load campaigns',
                  message: error.toString(),
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(donorFollowedPreviewProvider),
                ),
              ),
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                    child: EmptyState(
                      icon: Icons.favorite_border,
                      title: 'Not following any campaigns',
                      message: 'Tap follow on a campaign to track it here.',
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                  itemCount: campaigns.length,
                  separatorBuilder: (_, index) => const SizedBox(height: AppTheme.spacing16),
                  itemBuilder: (_, index) {
                    final campaign = campaigns[index];
                    return CampaignCard(
                      campaign: campaign,
                      isFollowed: true,
                      onTap: () => context.go(AppRoutes.campaignDetail(campaign.id)),
                      onFollowTap: () {},
                    );
                  },
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionButton(icon: Icons.search, label: 'Browse', onTap: onBrowse, isPrimary: true),
          const SizedBox(width: AppTheme.spacing12),
          _ActionButton(icon: Icons.payments_outlined, label: 'Donations', onTap: onDonations),
          const SizedBox(width: AppTheme.spacing12),
          _ActionButton(icon: Icons.visibility_off_outlined, label: 'Anonymous', onTap: onAnonymous),
          const SizedBox(width: AppTheme.spacing12),
          _ActionButton(icon: Icons.favorite_border, label: 'Following', onTap: onFollowing),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surface,
      borderRadius: AppTheme.borderRadiusPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadiusPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing8),
          decoration: BoxDecoration(
            border: isPrimary ? null : Border.all(color: AppColors.border),
            borderRadius: AppTheme.borderRadiusPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isPrimary ? AppColors.surface : AppColors.textPrimary),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: isPrimary ? AppColors.surface : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
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
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppTheme.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(value, style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing4),
          Text(title, style: AppTextStyles.body),
        ],
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
        icon: Icons.error_outline,
        title: 'Unable to load donation',
        message: error.toString(),
      ),
      data: (donation) {
        if (donation == null) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'Donation not found',
            message: 'This donation is no longer available.',
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
    required this.onViewAll,
  });

  final String title;
  final String subtitle;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(title, style: AppTextStyles.title),
               const SizedBox(height: AppTheme.spacing4),
               Text(subtitle, style: AppTextStyles.body),
            ],
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.label,
          ),
          child: const Text('View all'),
        ),
      ],
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return LoadingSkeleton(
      height: height,
      borderRadius: AppTheme.radiusLg,
    );
  }
}
