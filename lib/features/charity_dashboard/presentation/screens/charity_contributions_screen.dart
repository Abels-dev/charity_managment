import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/charity_dashboard/presentation/providers/charity_contributions_provider.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/widgets/donation_activity_card.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

import 'package:charity_managment/core/widgets/empty_state.dart';
import 'package:charity_managment/core/widgets/loading_skeleton.dart';
import 'package:charity_managment/core/theme/app_theme.dart';

class CharityContributionsScreen extends ConsumerWidget {
  const CharityContributionsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(charityContributionsProvider);
    await ref.read(charityContributionsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(charityContributionsProvider);

    return AppScaffold(
      title: 'Contributions',
      drawer: const AppNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: contributionsAsync.when(
          loading: () => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacing12),
            itemBuilder: (_, __) => const LoadingSkeleton(
              height: 90,
              borderRadius: AppTheme.radiusLg,
            ),
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              EmptyState(
                icon: Icons.error_outline,
                title: 'Unable to load contributions',
                message: error.toString(),
                actionLabel: 'Retry',
                onAction: () => _refresh(ref),
              ),
            ],
          ),
          data: (contributions) {
            if (contributions.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  EmptyState(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'No contributions yet',
                    message: 'Donations to your campaigns will appear here.',
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: contributions.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacing12),
              itemBuilder: (context, index) {
                return DonationActivityCard(activity: contributions[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
