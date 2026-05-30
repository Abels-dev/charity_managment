import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/close_campaign_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/charity_dashboard/domain/dashboard_summary.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/providers/campaign_analytics_provider.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/providers/dashboard_summary_provider.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/providers/recent_donations_provider.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/widgets/campaign_analytics_card.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/widgets/dashboard_stat_card.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/widgets/donation_activity_card.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

import 'package:charity_managment/core/widgets/empty_state.dart';
import 'package:charity_managment/core/widgets/loading_skeleton.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';

class CharityDashboardScreen extends ConsumerWidget {
  const CharityDashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(campaignAnalyticsProvider);
    ref.invalidate(recentDonationsProvider);

    await Future.wait([
      ref.read(dashboardSummaryProvider.future),
      ref.read(campaignAnalyticsProvider.future),
      ref.read(recentDonationsProvider.future),
    ]);
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
    ref.invalidate(campaignAnalyticsProvider);
    ref.invalidate(dashboardSummaryProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final analyticsAsync = ref.watch(campaignAnalyticsProvider);
    final donationsAsync = ref.watch(recentDonationsProvider);
    final closingIds = ref.watch(closeCampaignProvider).valueOrNull ?? <String>{};

    return AppScaffold(
      title: 'Dashboard',
      drawer: const AppNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Quick Actions
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _QuickActionChip(
                    icon: Icons.campaign,
                    label: 'My Campaigns',
                    onTap: () => context.go(AppRoutes.myCampaigns),
                  ),
                  _QuickActionChip(
                    icon: Icons.add_circle_outline,
                    label: 'Create',
                    onTap: () => context.go(AppRoutes.createCampaign),
                  ),
                  _QuickActionChip(
                    icon: Icons.volunteer_activism,
                    label: 'Contributions',
                    onTap: () => context.go(AppRoutes.charityContributions),
                  ),
                  _QuickActionChip(
                    icon: Icons.account_balance_outlined,
                    label: 'Bank Accounts',
                    onTap: () => context.go(AppRoutes.bankAccounts),
                  ),
                  _QuickActionChip(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () => context.go(AppRoutes.profile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Section Header: Overview
            _SectionHeader(title: 'Overview'),
            const SizedBox(height: AppTheme.spacing12),
            summaryAsync.when(
              loading: () => _StatGridSkeleton(),
              error: (error, _) => _SectionErrorState(
                title: 'Unable to load summary',
                message: error.toString(),
                onRetry: () => _refresh(ref),
              ),
              data: (summary) {
                if (!summary.hasCampaigns) {
                  return _EmptyOverviewState(
                    onCreate: () => context.go(AppRoutes.createCampaign),
                  );
                }
                return _DashboardSummaryGrid(summary: summary);
              },
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Section Header: Campaign Performance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionHeader(title: 'Campaign Performance'),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.myCampaigns),
                  child: Text(
                    'View all',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            analyticsAsync.when(
              loading: () => Column(
                children: [
                  for (int i = 0; i < 2; i++) ...[
                    const LoadingSkeleton(height: 140, borderRadius: AppTheme.radiusLg),
                    const SizedBox(height: AppTheme.spacing12),
                  ],
                ],
              ),
              error: (error, _) => _SectionErrorState(
                title: 'Unable to load analytics',
                message: error.toString(),
                onRetry: () => _refresh(ref),
              ),
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return const EmptyState(
                    icon: Icons.bar_chart_outlined,
                    title: 'No campaign analytics yet',
                    message: 'Launch your first campaign to see performance insights.',
                  );
                }

                return Column(
                  children: [
                    for (final analytics in campaigns) ...[
                      CampaignAnalyticsCard(
                        analytics: analytics,
                        isClosing: closingIds.contains(analytics.campaignId),
                        onView: () => context.go(
                          AppRoutes.campaignDetail(analytics.campaignId),
                        ),
                        onEdit: () => context.go(
                          AppRoutes.editCampaign(analytics.campaignId),
                        ),
                        onClose: () => _confirmCloseCampaign(
                          context,
                          ref,
                          analytics.campaignId,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Section Header: Recent Donations
            _SectionHeader(title: 'Recent Donations'),
            const SizedBox(height: AppTheme.spacing12),
            donationsAsync.when(
              loading: () => Column(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    const LoadingSkeleton(height: 80, borderRadius: AppTheme.radiusLg),
                    const SizedBox(height: AppTheme.spacing12),
                  ],
                ],
              ),
              error: (error, _) => _SectionErrorState(
                title: 'Unable to load donations',
                message: error.toString(),
                onRetry: () => _refresh(ref),
              ),
              data: (donations) {
                if (donations.isEmpty) {
                  return const EmptyState(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'No donations yet',
                    message: 'Once donations arrive, they will appear here instantly.',
                  );
                }

                return Column(
                  children: [
                    for (final donation in donations) ...[
                      DonationActivityCard(activity: donation),
                      const SizedBox(height: AppTheme.spacing12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppTheme.spacing32),
          ],
        ),
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.label.copyWith(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacing8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: AppColors.primary),
        label: Text(label, style: AppTextStyles.micro.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusPill),
        onPressed: onTap,
      ),
    );
  }
}

class _DashboardSummaryGrid extends StatelessWidget {
  const _DashboardSummaryGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth > 560 ? 3 : 2;
        const spacing = 12.0;
        final itemWidth = (maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'TOTAL CAMPAIGNS',
                value: summary.totalCampaigns.toString(),
                icon: Icons.view_list,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'ACTIVE',
                value: summary.activeCampaigns.toString(),
                icon: Icons.play_circle_outline,
                tint: AppColors.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'TOTAL RAISED',
                value: CampaignFormatters.money(summary.totalRaised),
                icon: Icons.savings_outlined,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'TOTAL DONORS',
                value: summary.totalDonors.toString(),
                icon: Icons.group_outlined,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'CLOSED',
                value: summary.closedCampaigns.toString(),
                icon: Icons.lock_outline,
                tint: const Color(0xFFEA580C),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(width: 160, child: LoadingSkeleton(height: 80, borderRadius: AppTheme.radiusLg)),
        SizedBox(width: 160, child: LoadingSkeleton(height: 80, borderRadius: AppTheme.radiusLg)),
        SizedBox(width: 160, child: LoadingSkeleton(height: 80, borderRadius: AppTheme.radiusLg)),
      ],
    );
  }
}

class _SectionErrorState extends StatelessWidget {
  const _SectionErrorState({
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
        EmptyState(
          icon: Icons.error_outline,
          title: title,
          message: message,
          actionLabel: 'Retry',
          onAction: onRetry,
        ),
      ],
    );
  }
}

class _EmptyOverviewState extends StatelessWidget {
  const _EmptyOverviewState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const EmptyState(
          icon: Icons.campaign_outlined,
          title: 'No campaigns yet',
          message: 'Create a campaign to start tracking your impact.',
        ),
        const SizedBox(height: AppTheme.spacing12),
        AppButton(
          text: 'Create Campaign',
          onPressed: onCreate,
        ),
      ],
    );
  }
}
