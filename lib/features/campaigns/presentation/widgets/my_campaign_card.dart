import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/models/campaign.dart';

import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/category_badge.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';

class MyCampaignCard extends StatelessWidget {
  const MyCampaignCard({
    super.key,
    required this.campaign,
    required this.onView,
    required this.onEdit,
    required this.onClose,
    required this.isClosing,
  });

  final Campaign campaign;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final bool isClosing;

  @override
  Widget build(BuildContext context) {
    final canEdit = campaign.status != CampaignStatus.closed;
    final canClose = campaign.status == CampaignStatus.active;

    return AppCard(
      onTap: onView,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CategoryBadge(category: campaign.category.label),
                              const SizedBox(width: AppTheme.spacing8),
                              CampaignStatusBadge(status: campaign.status),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Text(
                            campaign.title,
                            style: AppTextStyles.title,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  campaign.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: AppColors.textBody),
                    const SizedBox(width: AppTheme.spacing4),
                    Text(
                      campaign.organizationName,
                      style: AppTextStyles.label.copyWith(color: AppColors.textBody),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
                ClipRRect(
                  borderRadius: AppTheme.borderRadiusPill,
                  child: LinearProgressIndicator(
                    value: campaign.progress,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CampaignFormatters.percent(campaign.progress)} funded',
                      style: AppTextStyles.label.copyWith(color: AppColors.primary),
                    ),
                    Text(
                      '${CampaignFormatters.money(campaign.currentAmount)} / ${CampaignFormatters.money(campaign.goalAmount)}',
                      style: AppTextStyles.label.copyWith(color: AppColors.textBody),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
                Wrap(
                  spacing: AppTheme.spacing8,
                  runSpacing: AppTheme.spacing8,
                  children: [
                    OutlinedButton(
                      onPressed: onView,
                      child: const Text('View Campaign'),
                    ),
                    OutlinedButton(
                      onPressed: canEdit ? onEdit : null,
                      child: const Text('Edit Campaign'),
                    ),
                    FilledButton(
                      onPressed: (canClose && !isClosing) ? onClose : null,
                      child: isClosing
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Close Campaign'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
