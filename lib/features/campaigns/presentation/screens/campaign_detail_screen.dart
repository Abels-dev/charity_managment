import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/features/donations/presentation/widgets/donation_form_sheet.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

import 'package:charity_managment/core/widgets/empty_state.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/category_badge.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';

class _CampaignHeroAvatar extends StatelessWidget {
  const _CampaignHeroAvatar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final initial = title.trim().isEmpty ? '?' : title.trim()[0].toUpperCase();

    return Container(
      width: double.infinity,
      height: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.display.copyWith(
          fontSize: 96,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CampaignDetailScreen extends ConsumerWidget {
  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final detailAsync = ref.watch(campaignDetailProvider(campaignId));

    return AppScaffold(
      title: 'Campaign Detail',
      drawer: const AppNavigationDrawer(),
      showNotificationAction: auth.isAuthenticated,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Unable to load campaign',
          message: error.toString(),
        ),
        data: (campaign) {
          if (campaign == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'Campaign not found',
              message: 'This campaign may have been removed.',
            );
          }

          final isFollowed = ref.watch(isCampaignFollowedProvider(campaign.id));
          final followController = ref.read(campaignFollowProvider.notifier);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppTheme.radiusXl),
                        bottomRight: Radius.circular(AppTheme.radiusXl),
                      ),
                      child: _CampaignHeroAvatar(title: campaign.title),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: AppTheme.spacing8,
                                  runSpacing: AppTheme.spacing8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    CategoryBadge(category: campaign.category.label),
                                    CampaignStatusBadge(status: campaign.status),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFollowed ? Icons.favorite : Icons.favorite_border,
                                  color: isFollowed ? AppColors.error : AppColors.textBody,
                                ),
                                onPressed: () {
                                  if (!auth.isAuthenticated) {
                                    _promptSignIn(context);
                                    return;
                                  }
                                  followController.toggleFollow(campaign.id);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          Text(
                            campaign.title,
                            style: AppTextStyles.display.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => context.go(AppRoutes.charityProfile(campaign.charityId)),
                              child: Row(
                                children: [
                                  const Icon(Icons.business, size: 20, color: AppColors.textBody),
                                  const SizedBox(width: AppTheme.spacing8),
                                  Expanded(
                                    child: Text(
                                      campaign.organizationName,
                                      style: AppTextStyles.label.copyWith(color: AppColors.textBody),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing32),

                          ClipRRect(
                            borderRadius: AppTheme.borderRadiusPill,
                            child: LinearProgressIndicator(
                              value: campaign.progress,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    CampaignFormatters.money(campaign.currentAmount),
                                    style: AppTextStyles.title.copyWith(color: AppColors.primary),
                                  ),
                                  Text(
                                        'raised of ${CampaignFormatters.money(campaign.goalAmount)}',
                                    style: AppTextStyles.body,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                        CampaignFormatters.percent(campaign.progress),
                                    style: AppTextStyles.title,
                                  ),
                                  Text(
                                    'funded',
                                    style: AppTextStyles.body,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing48),

                          Text('About this campaign', style: AppTextStyles.title),
                          const SizedBox(height: AppTheme.spacing16),
                          Text(
                            campaign.description,
                            style: AppTextStyles.body.copyWith(height: 1.6),
                          ),
                          const SizedBox(height: AppTheme.spacing32),

                          AppCard(
                            padding: const EdgeInsets.all(AppTheme.spacing16),
                            child: Column(
                              children: [
                                _MetaRow(
                                  label: 'Location',
                                  value: campaign.location ?? 'N/A',
                                  icon: Icons.location_on_outlined,
                                ),
                                const Divider(color: AppColors.border, height: 24),
                                _MetaRow(
                                  label: 'Start date',
                                  value: CampaignFormatters.shortDate(campaign.startDate),
                                  icon: Icons.calendar_today_outlined,
                                ),
                                const Divider(color: AppColors.border, height: 24),
                                _MetaRow(
                                  label: 'End date',
                                  value: CampaignFormatters.shortDate(campaign.endDate),
                                  icon: Icons.event_outlined,
                                ),
                                const Divider(color: AppColors.border, height: 24),
                                _MetaRow(
                                  label: 'Donors',
                                  value: '${campaign.donorCount}',
                                  icon: Icons.people_outline,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: AppButton(
                    text: 'Donate Now',
                    onPressed: campaign.status == CampaignStatus.closed
                        ? null
                        : () {
                            if (!auth.isAuthenticated) {
                              _promptSignIn(context);
                              return;
                            }
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              backgroundColor: AppColors.background,
                              builder: (_) => DonationFormSheet(
                                campaign: campaign,
                                onSuccess: (donationId) {
                                  context.go(AppRoutes.donationSuccess(donationId));
                                },
                              ),
                            );
                          },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _promptSignIn(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sign in to donate or follow campaigns.'),
        action: SnackBarAction(
          label: 'Sign in',
          onPressed: () => context.go(AppRoutes.roleSelection),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textBody),
        const SizedBox(width: AppTheme.spacing12),
        Text(
          label,
          style: AppTextStyles.body,
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.label,
        ),
      ],
    );
  }
}
