import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_receipt_provider.dart';
import 'package:charity_managment/features/donations/presentation/widgets/receipt_info_row.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/donation_receipt.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class DonationReceiptScreen extends ConsumerWidget {
  const DonationReceiptScreen({
    super.key,
    required this.donationId,
  });

  final String donationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationAsync = ref.watch(donationDetailProvider(donationId));
    final receiptAsync = ref.watch(donationReceiptProvider(donationId));

    return AppScaffold(
      title: 'Receipt',
      drawer: const AppNavigationDrawer(),
      body: donationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load receipt',
          subtitle: error.toString(),
        ),
        data: (donation) {
          if (donation == null) {
            return const EmptyState(
              title: 'Donation not found',
              subtitle: 'This donation may have been removed.',
            );
          }

          return receiptAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              title: 'Unable to load receipt',
              subtitle: error.toString(),
            ),
            data: (receipt) {
              if (receipt == null) {
                return const EmptyState(
                  title: 'Receipt unavailable',
                  subtitle: 'Please try again later.',
                );
              }

              return _ReceiptBody(
                donation: donation,
                receipt: receipt,
              );
            },
          );
        },
      ),
    );
  }
}

class _ReceiptBody extends ConsumerWidget {
  const _ReceiptBody({
    required this.donation,
    required this.receipt,
  });

  final Donation donation;
  final DonationReceipt receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignAsync = ref.watch(campaignDetailProvider(donation.campaignId));
    final campaignTitle = campaignAsync.valueOrNull?.title ?? 'Campaign ${donation.campaignId}';
    final auth = ref.watch(authControllerProvider).user;
    final donorName = donation.isAnonymous
        ? 'Anonymous donor'
        : (auth?.fullName ?? 'Donor');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donation Receipt',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Reference ${receipt.reference}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ReceiptInfoRow(label: 'Donor', value: donorName),
                ReceiptInfoRow(label: 'Campaign', value: campaignTitle),
                ReceiptInfoRow(
                  label: 'Amount',
                  value: CampaignFormatters.money(donation.amount),
                ),
                ReceiptInfoRow(
                  label: 'Date',
                  value: CampaignFormatters.shortDate(donation.donatedAt),
                ),
                ReceiptInfoRow(
                  label: 'Transaction',
                  value: donation.transactionId,
                ),
                ReceiptInfoRow(
                  label: 'Status',
                  value: donation.status.label,
                ),
                if (donation.message != null && donation.message!.isNotEmpty)
                  ReceiptInfoRow(
                    label: 'Message',
                    value: donation.message!,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share receipt coming soon.')),
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download coming soon.')),
                  );
                },
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
