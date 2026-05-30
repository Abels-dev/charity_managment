import 'package:flutter/material.dart';

import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
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
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  campaignTitle,
                  style: AppTextStyles.label.copyWith(fontSize: 16),
                ),
              ),
              _DonationStatusBadge(status: donation.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CampaignFormatters.money(donation.amount),
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            'Donated on ${CampaignFormatters.shortDate(donation.donatedAt)}',
            style: AppTextStyles.micro,
          ),
          const SizedBox(height: 4),
          Text(
            donation.isAnonymous ? 'Anonymous donation' : 'Donor visible',
            style: AppTextStyles.micro.copyWith(color: AppColors.textBody.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'View Receipt',
            type: AppButtonType.secondary,
            onPressed: onTap,
            icon: const Icon(Icons.receipt_long, size: 18),
          ),
        ],
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
    final (background, foreground) = switch (status) {
      DonationStatus.completed => (AppColors.primaryBg, AppColors.primary),
      DonationStatus.pending => (Colors.amber.shade50, Colors.amber.shade900),
      DonationStatus.failed => (Colors.red.shade50, AppColors.error),
      DonationStatus.refunded => (AppColors.border, AppColors.textPrimary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.micro.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
