import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/charity_dashboard/domain/donation_activity.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/utils/dashboard_formatters.dart';

import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';

class DonationActivityCard extends StatelessWidget {
  const DonationActivityCard({
    super.key,
    required this.activity,
  });

  final DonationActivity activity;

  @override
  Widget build(BuildContext context) {
    final isAnonymous = activity.donorName.isEmpty || activity.donorName.toLowerCase() == 'anonymous';

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: AppTheme.borderRadiusMd,
            ),
            child: Center(
              child: Text(
                isAnonymous
                    ? '?'
                    : activity.donorName.substring(0, 1).toUpperCase(),
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              isAnonymous ? 'Anonymous' : activity.donorName,
                              style: AppTextStyles.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isAnonymous) ...[
                            const SizedBox(width: AppTheme.spacing8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: AppTheme.borderRadiusPill,
                              ),
                              child: Text(
                                'Anonymous',
                                style: AppTextStyles.micro.copyWith(color: AppColors.textBody),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      CampaignFormatters.money(activity.amount),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  activity.campaignName,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textBody,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  DashboardFormatters.shortDateTime(activity.donatedAt),
                  style: AppTextStyles.micro.copyWith(color: AppColors.textBody),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
