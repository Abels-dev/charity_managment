import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_history_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_visibility_provider.dart';
import 'package:charity_managment/features/donations/presentation/widgets/donation_card.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_detail_provider.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class AnonymousDonationsScreen extends ConsumerWidget {
  const AnonymousDonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(donationHistoryProvider);
    final visibilityState = ref.watch(donationVisibilityProvider);
    final controller = ref.read(donationVisibilityProvider.notifier);

    return AppScaffold(
      title: 'Anonymous Donations',
      drawer: const AppNavigationDrawer(),
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load donations',
          subtitle: error.toString(),
        ),
        data: (donations) {
          final anonymous = donations.where((donation) => donation.isAnonymous).toList();

          if (anonymous.isEmpty) {
            return const EmptyState(
              title: 'No anonymous donations',
              subtitle: 'Mark a donation as anonymous to manage it here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(donationHistoryProvider);
              await ref.read(donationHistoryProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: anonymous.length + (visibilityState.hasError ? 1 : 0),
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (visibilityState.hasError && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      visibilityState.error.toString(),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }

                final donation = anonymous[visibilityState.hasError ? index - 1 : index];
                return _AnonymousDonationTile(
                  donationId: donation.id,
                  onMakeVisible: () => controller.setAnonymous(
                    donationId: donation.id,
                    isAnonymous: false,
                  ),
                  onOpenReceipt: () => context.go(
                    AppRoutes.donationReceipt(donation.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnonymousDonationTile extends ConsumerWidget {
  const _AnonymousDonationTile({
    required this.donationId,
    required this.onMakeVisible,
    required this.onOpenReceipt,
  });

  final String donationId;
  final VoidCallback onMakeVisible;
  final VoidCallback onOpenReceipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationAsync = ref.watch(donationDetailProvider(donationId));

    return donationAsync.when(
      loading: () => const SizedBox(height: 90, child: Center(child: CircularProgressIndicator())),
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
        final campaignTitle = campaignAsync.valueOrNull?.title ?? 'Campaign ${donation.campaignId}';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DonationCard(
                  donation: donation,
                  campaignTitle: campaignTitle,
                  onTap: onOpenReceipt,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenReceipt,
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Receipt'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onMakeVisible,
                        icon: const Icon(Icons.visibility),
                        label: const Text('Make visible'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
