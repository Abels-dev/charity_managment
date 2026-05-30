import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/models/donation.dart';

class DonationSuccessCard extends StatelessWidget {
  const DonationSuccessCard({
    super.key,
    required this.donation,
  });

  final Donation donation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Donation confirmed',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              CampaignFormatters.money(donation.amount),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Transaction ${donation.transactionId}',
              style: theme.textTheme.bodyMedium,
            ),
            if (donation.guestName != null && donation.guestName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Donor ${donation.guestName}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Donated on ${CampaignFormatters.shortDate(donation.donatedAt)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
