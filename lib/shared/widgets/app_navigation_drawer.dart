import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/routing/app_routes.dart';

class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Campaigns'),
              onTap: () => context.go(AppRoutes.campaigns),
            ),
            ListTile(
              title: const Text('Donations'),
              onTap: () => context.go(AppRoutes.donations),
            ),
            ListTile(
              title: const Text('Notifications'),
              onTap: () => context.go(AppRoutes.notifications),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () => context.go(AppRoutes.profile),
            ),
            if (auth.user?.role == UserRole.charityOrganization)
              ListTile(
                title: const Text('Charity Dashboard'),
                onTap: () => context.go(AppRoutes.charityDashboard),
              ),
            const Divider(),
            ListTile(
              title: const Text('Sign Out'),
              onTap: () async {
                await authController.logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
