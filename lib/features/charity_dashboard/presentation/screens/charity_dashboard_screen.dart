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
import 'package:charity_managment/features/charity_dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/widgets/dashboard_stat_card.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/widgets/donation_activity_card.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

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
      title: 'Charity Dashboard',
      drawer: const AppNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _QuickActionsRow(
              onMyCampaigns: () => context.go(AppRoutes.myCampaigns),
              onCreateCampaign: () => context.go(AppRoutes.createCampaign),
              onContributions: () => context.go(AppRoutes.charityContributions),
              onRequests: () => context.go(AppRoutes.charityCampaignRequests),
              onBankAccounts: () => context.go(AppRoutes.bankAccounts),
              onNotifications: () => context.go(AppRoutes.notifications),
              onProfile: () => context.go(AppRoutes.profile),
            ),
            const SizedBox(height: 16),
            const DashboardSectionHeader(
              title: 'Overview',
              subtitle: 'Live snapshot of your charity performance.',
            ),
            const SizedBox(height: 12),
            summaryAsync.when(
              loading: () => const _DashboardSummaryLoading(),
              error: (error, _) => _SectionErrorState(
                title: 'Unable to load dashboard summary',
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
            const SizedBox(height: 20),
            DashboardSectionHeader(
              title: 'Campaign performance',
              subtitle: 'Track the progress of each campaign.',
              trailing: TextButton(
                onPressed: () => context.go(AppRoutes.myCampaigns),
                child: const Text('My campaigns'),
              ),
            ),
            const SizedBox(height: 12),
            analyticsAsync.when(
              loading: () => const _SectionLoading(height: 180),
              error: (error, _) => _SectionErrorState(
                title: 'Unable to load campaign analytics',
                message: error.toString(),
                onRetry: () => _refresh(ref),
              ),
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return EmptyState(
                    title: 'No campaign analytics yet',
                    subtitle: 'Launch your first campaign to see performance insights.',
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
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            const DashboardSectionHeader(
              title: 'Recent donations',
              subtitle: 'Latest contributions across your campaigns.',
            ),
            const SizedBox(height: 12),
            donationsAsync.when(
              loading: () => const _SectionLoading(height: 140),
              error: (error, _) => _SectionErrorState(
                title: 'Unable to load donation activity',
                message: error.toString(),
                onRetry: () => _refresh(ref),
              ),
              data: (donations) {
                if (donations.isEmpty) {
                  return const EmptyState(
                    title: 'No donations yet',
                    subtitle: 'Once donations arrive, they will appear here instantly.',
                  );
                }

                return Column(
                  children: [
                    for (final donation in donations) ...[
                      DonationActivityCard(activity: donation),
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
    required this.onMyCampaigns,
    required this.onCreateCampaign,
    required this.onContributions,
    required this.onRequests,
    required this.onBankAccounts,
    required this.onNotifications,
    required this.onProfile,
  });

  final VoidCallback onMyCampaigns;
  final VoidCallback onCreateCampaign;
  final VoidCallback onContributions;
  final VoidCallback onRequests;
  final VoidCallback onBankAccounts;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onMyCampaigns,
          icon: const Icon(Icons.campaign),
          label: const Text('My Campaigns'),
        ),
        FilledButton.icon(
          onPressed: onCreateCampaign,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Create'),
        ),
        OutlinedButton.icon(
          onPressed: onContributions,
          icon: const Icon(Icons.volunteer_activism),
          label: const Text('Contributions'),
        ),
        OutlinedButton.icon(
          onPressed: onRequests,
          icon: const Icon(Icons.inbox_outlined),
          label: const Text('Requests'),
        ),
        OutlinedButton.icon(
          onPressed: onBankAccounts,
          icon: const Icon(Icons.account_balance_outlined),
          label: const Text('Bank Accounts'),
        ),
        OutlinedButton.icon(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_outlined),
          label: const Text('Notifications'),
        ),
        OutlinedButton.icon(
          onPressed: onProfile,
          icon: const Icon(Icons.person_outline),
          label: const Text('Profile'),
        ),
      ],
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
        final spacing = 12.0;
        final itemWidth = (maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'Total campaigns',
                value: summary.totalCampaigns.toString(),
                icon: Icons.view_list,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'Active campaigns',
                value: summary.activeCampaigns.toString(),
                icon: Icons.play_circle_outline,
                tint: Colors.green,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'Closed campaigns',
                value: summary.closedCampaigns.toString(),
                icon: Icons.lock_outline,
                tint: Colors.orange,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'Total raised',
                value: CampaignFormatters.money(summary.totalRaised),
                icon: Icons.savings_outlined,
                tint: Colors.indigo,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardStatCard(
                title: 'Total donors',
                value: summary.totalDonors.toString(),
                icon: Icons.group_outlined,
                tint: Colors.teal,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardSummaryLoading extends StatelessWidget {
  const _DashboardSummaryLoading();

  @override
  Widget build(BuildContext context) {
    return const _SectionLoading(height: 180);
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

class _EmptyOverviewState extends StatelessWidget {
  const _EmptyOverviewState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const EmptyState(
          title: 'No campaigns yet',
          subtitle: 'Create a campaign to start tracking your impact.',
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: onCreate,
          child: const Text('Create Campaign'),
        ),
      ],
    );
  }
}
