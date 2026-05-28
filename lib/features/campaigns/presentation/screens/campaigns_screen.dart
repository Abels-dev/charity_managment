import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_filters_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaigns_list_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_category_filter.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_list_loading.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_search_bar.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

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
          CampaignSearchBar(
            controller: _searchController,
            onChanged: filterController.setSearchQuery,
          ),
          const SizedBox(height: 12),
          CampaignCategoryFilter(
            selectedCategory: filters.category,
            onSelected: (CampaignCategory? category) {
              filterController.setCategory(category);
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: campaignsAsync.when(
                loading: () => const CampaignListLoading(),
                error: (error, _) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      EmptyState(
                        title: 'Unable to load campaigns',
                        subtitle: error.toString(),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.invalidate(campaignsListProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  );
                },
                data: (campaigns) {
                  if (campaigns.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        EmptyState(
                          title: 'No campaigns found',
                          subtitle: 'Try changing keyword or category filter.',
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: campaigns.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
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
