import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_unread_count_provider.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/routing/app_routes.dart';

class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final isAuthenticated = auth.isAuthenticated;

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            if (!isAuthenticated)
              ListTile(
                title: const Text('Home'),
                onTap: () => context.go(AppRoutes.root),
              ),
            ListTile(
              title: const Text('Campaigns'),
              onTap: () => context.go(AppRoutes.campaigns),
            ),
            if (auth.user?.role == UserRole.donor)
              ListTile(
                title: const Text('Followed Campaigns'),
                onTap: () => context.go(AppRoutes.followedCampaigns),
              ),
            if (auth.user?.role == UserRole.charityOrganization)
              ListTile(
                title: const Text('My Campaigns'),
                onTap: () => context.go(AppRoutes.myCampaigns),
              ),
            if (auth.user?.role == UserRole.charityOrganization)
              ListTile(
                title: const Text('Create Campaign'),
                onTap: () => context.go(AppRoutes.createCampaign),
              ),
            if (auth.user?.role == UserRole.donor)
              ListTile(
                title: const Text('Donations'),
                onTap: () => context.go(AppRoutes.donations),
              ),
            if (auth.user?.role == UserRole.donor)
              ListTile(
                title: const Text('Anonymous Donations'),
                onTap: () => context.go(AppRoutes.anonymousDonations),
              ),
            if (isAuthenticated)
              ListTile(
                title: const Text('Notifications'),
                trailing: _NotificationBadge(),
                onTap: () => context.go(AppRoutes.notifications),
              ),
            if (isAuthenticated)
              ListTile(
                title: const Text('Profile'),
                onTap: () => context.go(AppRoutes.profile),
              ),
            if (auth.user?.role == UserRole.charityOrganization)
              ListTile(
                title: const Text('Charity Dashboard'),
                onTap: () => context.go(AppRoutes.charityDashboard),
              ),
            if (auth.user?.role == UserRole.charityOrganization)
              ListTile(
                title: const Text('Contributions'),
                onTap: () => context.go(AppRoutes.charityContributions),
              ),
            if (auth.user?.role == UserRole.charityOrganization)
              ListTile(
                title: const Text('Campaign Requests'),
                onTap: () => context.go(AppRoutes.charityCampaignRequests),
              ),
            const Divider(),
            if (isAuthenticated)
              ListTile(
                title: const Text('Sign Out'),
                onTap: () async {
                  await authController.logout();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
              )
            else ...[
              ListTile(
                title: const Text('Sign In'),
                onTap: () => context.go(AppRoutes.login),
              ),
              ListTile(
                title: const Text('Create Account'),
                onTap: () => context.go(AppRoutes.roleSelection),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationBadge extends ConsumerWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;
    if (unreadCount == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final label = unreadCount > 99 ? '99+' : unreadCount.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
