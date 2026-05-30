import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_filters_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaigns_list_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_category_filter.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_search_bar.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

import 'package:charity_managment/core/widgets/empty_state.dart';
import 'package:charity_managment/core/widgets/loading_skeleton.dart';
import 'package:charity_managment/core/theme/app_theme.dart';

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(campaignFiltersProvider);
    _searchController = TextEditingController(text: filters.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(campaignsListProvider);
    await ref.read(campaignsListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final campaignsAsync = ref.watch(campaignsListProvider);
    final filters = ref.watch(campaignFiltersProvider);
    final filterController = ref.read(campaignFiltersProvider.notifier);
    final followController = ref.read(campaignFollowProvider.notifier);
    final followedIds = ref.watch(campaignFollowProvider).valueOrNull ?? <String>{};

    return AppScaffold(
      title: 'Campaigns',
      drawer: const AppNavigationDrawer(),
      showNotificationAction: auth.isAuthenticated,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: CampaignSearchBar(
              controller: _searchController,
              onChanged: filterController.setSearchQuery,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: CampaignCategoryFilter(
              selectedCategory: filters.category,
              onSelected: (CampaignCategory? category) {
                filterController.setCategory(category);
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: campaignsAsync.when(
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, index) => const SizedBox(height: AppTheme.spacing16),
                  itemBuilder: (_, index) => const LoadingSkeleton(height: 200, borderRadius: AppTheme.radiusLg),
                ),
                error: (error, _) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      EmptyState(
                        icon: Icons.error_outline,
                        title: 'Unable to load campaigns',
                        message: error.toString(),
                        actionLabel: 'Retry',
                        onAction: () => ref.invalidate(campaignsListProvider),
                      ),
                    ],
                  );
                },
                data: (campaigns) {
                  if (campaigns.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        EmptyState(
                          icon: Icons.search_off,
                          title: 'No campaigns found',
                          message: 'Try changing keyword or category filter.',
                          actionLabel: 'Clear filters',
                          onAction: () {
                            _searchController.clear();
                            filterController.setSearchQuery('');
                            filterController.setCategory(null);
                          },
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing8),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: campaigns.length,
                    separatorBuilder: (_, index) => const SizedBox(height: AppTheme.spacing16),
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      final campaignId = campaign.id;
                      final isFollowed = followedIds.contains(campaignId);

                      return CampaignCard(
                        campaign: campaign,
                        isFollowed: isFollowed,
                        onTap: () => context.go(AppRoutes.campaignDetail(campaignId)),
                        onFollowTap: () {
                          if (!auth.isAuthenticated) {
                            _promptSignIn(context);
                            return;
                          }
                          followController.toggleFollow(campaignId);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _promptSignIn(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sign in to follow campaigns.'),
        action: SnackBarAction(
          label: 'Sign in',
          onPressed: () => context.go(AppRoutes.roleSelection),
        ),
      ),
    );
  }
}
