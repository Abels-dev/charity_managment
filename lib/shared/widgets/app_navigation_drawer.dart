import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';

class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final isAuthenticated = auth.isAuthenticated;
    final user = auth.user;
    final isDonor = user?.role == UserRole.donor;
    final isCharity = user?.role == UserRole.charityOrganization;

    String location = '';
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {
    }

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          Material(
            color: AppColors.surface,
            child: InkWell(
              onTap: isAuthenticated
                  ? () {
                      Navigator.pop(context);
                      context.go(AppRoutes.profile);
                    }
                  : null,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + AppTheme.spacing24,
                  left: AppTheme.spacing24,
                  right: AppTheme.spacing24,
                  bottom: AppTheme.spacing24,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryBg,
                      child: Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                        style: AppTextStyles.title.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Guest',
                            style: AppTextStyles.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppTheme.borderRadiusPill,
                            ),
                            child: Text(
                              isCharity ? 'Charity' : isDonor ? 'Donor' : 'Guest',
                              style: AppTextStyles.micro.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
              children: [
                if (!isAuthenticated) ...[
                  _DrawerItem(icon: Icons.home_outlined, label: 'Home', route: AppRoutes.root, currentRoute: location),
                  _DrawerItem(icon: Icons.campaign_outlined, label: 'Campaigns', route: AppRoutes.campaigns, currentRoute: location),
                  const Divider(color: AppColors.border, height: AppTheme.spacing24),
                  _DrawerItem(icon: Icons.login, label: 'Sign In', route: AppRoutes.login, currentRoute: location),
                  _DrawerItem(icon: Icons.person_add_outlined, label: 'Create Account', route: AppRoutes.roleSelection, currentRoute: location),
                ] else if (isDonor) ...[
                  _DrawerItem(icon: Icons.home_outlined, label: 'Home', route: AppRoutes.root, currentRoute: location),
                  _DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.donorDashboard, currentRoute: location),
                  _DrawerItem(icon: Icons.campaign_outlined, label: 'All Campaigns', route: AppRoutes.campaigns, currentRoute: location),
                  _DrawerItem(icon: Icons.favorite_border, label: 'My Campaigns (Following)', route: AppRoutes.followedCampaigns, currentRoute: location),
                  _DrawerItem(icon: Icons.receipt_long_outlined, label: 'Donation History', route: AppRoutes.donations, currentRoute: location),
                ] else if (isCharity) ...[
                  _DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.charityDashboard, currentRoute: location),
                  _DrawerItem(icon: Icons.add_circle_outline, label: 'Create Campaign', route: AppRoutes.createCampaign, currentRoute: location),
                  _DrawerItem(icon: Icons.list_alt, label: 'My Campaigns', route: AppRoutes.myCampaigns, currentRoute: location),
                  _DrawerItem(icon: Icons.campaign_outlined, label: 'All Campaigns', route: AppRoutes.campaigns, currentRoute: location),
                  _DrawerItem(icon: Icons.volunteer_activism_outlined, label: 'Contributions', route: AppRoutes.charityContributions, currentRoute: location),
                  _DrawerItem(icon: Icons.mark_email_unread_outlined, label: 'Campaign Requests', route: AppRoutes.charityCampaignRequests, currentRoute: location),
                ],
              ],
            ),
          ),

          if (isAuthenticated)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text('Sign Out', style: AppTextStyles.label.copyWith(color: AppColors.error)),
                onTap: () async {
                  await authController.logout();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing8, vertical: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: AppTheme.borderRadiusMd,
        border: Border(
          left: BorderSide(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textBody,
        ),
        title: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isActive ? AppColors.primary : AppColors.textBody,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusMd),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
