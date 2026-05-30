import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_receipt_provider.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/donation_receipt.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';
import 'package:charity_managment/core/widgets/app_card.dart';

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
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donation Receipt',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ref: ${receipt.reference}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ReceiptField(label: 'Donor', value: donorName),
              _ReceiptField(label: 'Campaign', value: campaignTitle),
              _ReceiptField(
                label: 'Amount',
                value: CampaignFormatters.money(donation.amount),
                isHighlight: true,
              ),
              _ReceiptField(
                label: 'Date',
                value: CampaignFormatters.shortDate(donation.donatedAt),
              ),
              _ReceiptField(
                label: 'Transaction ID',
                value: donation.transactionId,
              ),
              _ReceiptField(
                label: 'Status',
                value: donation.status.label,
              ),
              if (donation.message != null && donation.message!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ReceiptField(
                  label: 'Message',
                  value: donation.message!,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
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

class _ReceiptField extends StatelessWidget {
  const _ReceiptField({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? const Color(0xFF10B981) : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
