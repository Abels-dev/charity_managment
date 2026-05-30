import 'package:flutter/material.dart';

import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/features/charity_dashboard/domain/campaign_analytics.dart';

class CampaignAnalyticsCard extends StatelessWidget {
  const CampaignAnalyticsCard({
    super.key,
    required this.analytics,
    required this.onView,
    required this.onEdit,
    required this.onClose,
    required this.isClosing,
  });

  final CampaignAnalytics analytics;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final bool isClosing;

  @override
  Widget build(BuildContext context) {
    final canEdit = analytics.isClosed == false;
    final canClose = analytics.isActive;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  analytics.title,
                  style: AppTextStyles.label.copyWith(fontSize: 16),
                ),
              ),
              CampaignStatusBadge(status: analytics.status),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: analytics.progress,
            backgroundColor: AppColors.primaryBg,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            '${CampaignFormatters.percent(analytics.progress)} • ${CampaignFormatters.money(analytics.currentAmount)} / ${CampaignFormatters.money(analytics.targetAmount)}',
            style: AppTextStyles.micro.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${analytics.donorCount} donors',
            style: AppTextStyles.micro.copyWith(color: AppColors.textBody),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'View',
                  type: AppButtonType.secondary,
                  onPressed: onView,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Edit',
                  type: AppButtonType.outline,
                  onPressed: canEdit ? onEdit : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Close',
                  type: AppButtonType.primary,
                  onPressed: (canClose && !isClosing) ? onClose : null,
                  isLoading: isClosing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
