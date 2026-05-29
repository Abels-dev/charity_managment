import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/charity_dashboard/presentation/providers/charity_contributions_provider.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/widgets/donation_activity_card.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class CharityContributionsScreen extends ConsumerWidget {
  const CharityContributionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(charityContributionsProvider);

    return AppScaffold(
      title: 'Contributions',
      drawer: const AppNavigationDrawer(),
      body: contributionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load contributions',
          subtitle: error.toString(),
        ),
        data: (contributions) {
          if (contributions.isEmpty) {
            return const EmptyState(
              title: 'No contributions yet',
              subtitle: 'Donations to your campaigns will appear here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(charityContributionsProvider);
              await ref.read(charityContributionsProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: contributions.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return DonationActivityCard(activity: contributions[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
