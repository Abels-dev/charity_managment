import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/features/profile/presentation/providers/current_profile_provider.dart';
import 'package:charity_managment/features/profile/presentation/utils/profile_formatters.dart';
import 'package:charity_managment/features/profile/presentation/widgets/profile_header.dart';
import 'package:charity_managment/features/profile/presentation/widgets/profile_info_tile.dart';
import 'package:charity_managment/features/profile/presentation/widgets/profile_section_card.dart';
import 'package:charity_managment/features/profile/presentation/widgets/profile_stat_tile.dart';
import 'package:charity_managment/features/profile/presentation/widgets/verification_badge.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/async_value_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return AppScaffold(
      title: 'Profile',
      drawer: const AppNavigationDrawer(),
      body: AsyncValueView(
        value: profileAsync,
        data: (profile) {
          final user = profile.user;
          final charity = profile.charityProfile;
          final isCharity = user.role == ProfileRole.charity;
          final displayName = isCharity
              ? (charity?.organizationName ?? user.name)
              : user.name;
          final subtitle = user.email;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(
                  name: displayName,
                  subtitle: subtitle,
                  avatarName: displayName,
                  badge: isCharity
                      ? VerificationBadge(isVerified: user.isVerified)
                      : null,
                ),
                const SizedBox(height: 20),
                ProfileSectionCard(
                  title: 'About',
                  child: Column(
                    children: [
                      ProfileInfoTile(label: 'Email', value: user.email),
                      ProfileInfoTile(
                        label: 'Phone',
                        value: user.phone ?? 'Not provided',
                      ),
                      if (!isCharity)
                        ProfileInfoTile(
                          label: 'Bio',
                          value: user.bio ?? 'No bio added yet',
                        ),
                      if (isCharity)
                        ProfileInfoTile(
                          label: 'Description',
                          value: charity?.description ?? 'No description added yet',
                        ),
                      if (isCharity)
                        ProfileInfoTile(
                          label: 'Website',
                          value: charity?.website ?? 'Not provided',
                        ),
                      if (isCharity)
                        ProfileInfoTile(
                          label: 'Address',
                          value: charity?.address ?? 'Not provided',
                        ),
                      ProfileInfoTile(
                        label: 'Joined',
                        value: ProfileFormatters.shortDate(user.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ProfileSectionCard(
                  title: 'Impact',
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 420;
                      final tiles = <Widget>[
                        if (!isCharity)
                          ProfileStatTile(
                            label: 'Followed campaigns',
                            value: profile.followedCampaignsCount.toString(),
                          ),
                        if (!isCharity)
                          ProfileStatTile(
                            label: 'Donations',
                            value: profile.donationCount.toString(),
                          ),
                        if (isCharity)
                          ProfileStatTile(
                            label: 'Total campaigns',
                            value: profile.totalCampaignsCount.toString(),
                          ),
                      ];

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: tiles
                            .map(
                              (tile) => SizedBox(
                                width: isWide
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth,
                                child: tile,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ProfileSectionCard(
                  title: 'Settings',
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Account type'),
                        trailing: Text(user.role.label),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: false,
                        onChanged: null,
                        title: const Text('Dark mode'),
                        subtitle: const Text('Coming soon'),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: true,
                        onChanged: null,
                        title: const Text('Notifications'),
                        subtitle: const Text('Coming soon'),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Logout'),
                        leading: const Icon(Icons.logout),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.editProfile),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
