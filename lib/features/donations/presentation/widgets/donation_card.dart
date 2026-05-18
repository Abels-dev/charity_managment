import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/models/donation.dart';

class DonationCard extends StatelessWidget {
  const DonationCard({
    super.key,
    required this.donation,
    required this.campaignTitle,
    required this.onTap,
  });

  final Donation donation;
  final String campaignTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      campaignTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  _DonationStatusBadge(status: donation.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                CampaignFormatters.money(donation.amount),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Donated on ${CampaignFormatters.shortDate(donation.donatedAt)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                donation.isAnonymous ? 'Anonymous donation' : 'Donor visible',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonationStatusBadge extends StatelessWidget {
  const _DonationStatusBadge({
    required this.status,
  });

  final DonationStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      DonationStatus.completed => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      DonationStatus.pending => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
      DonationStatus.failed => (colorScheme.errorContainer, colorScheme.onErrorContainer),
      DonationStatus.refunded => (colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}
