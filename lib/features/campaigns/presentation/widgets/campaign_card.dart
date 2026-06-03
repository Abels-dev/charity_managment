import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/models/campaign.dart';

import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/category_badge.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';

class _CampaignInitialAvatar extends StatelessWidget {
  const _CampaignInitialAvatar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final initial = title.trim().isEmpty ? '?' : title.trim()[0].toUpperCase();
    const size = 48.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.title.copyWith(
          color: Colors.white,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    required this.isFollowed,
    required this.onTap,
    required this.onFollowTap,
  });

  final Campaign campaign;
  final bool isFollowed;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
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
                    _CampaignInitialAvatar(title: campaign.title),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppTheme.spacing8,
                            runSpacing: AppTheme.spacing4,
                            children: [
                              CategoryBadge(category: campaign.category.label),
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
                    IconButton(
                      icon: Icon(
                        isFollowed ? Icons.favorite : Icons.favorite_border,
                        color: isFollowed ? AppColors.error : AppColors.textBody,
                      ),
                      onPressed: onFollowTap,
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
                    Expanded(
                      child: Text(
                        campaign.organizationName,
                        style: AppTextStyles.label.copyWith(color: AppColors.textBody),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    Flexible(
                      child: Text(
                        '${CampaignFormatters.percent(campaign.progress)} funded',
                        style: AppTextStyles.label.copyWith(color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Flexible(
                      child: Text(
                        '${CampaignFormatters.money(campaign.currentAmount)} / ${CampaignFormatters.money(campaign.goalAmount)}',
                        style: AppTextStyles.label.copyWith(color: AppColors.textBody),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
