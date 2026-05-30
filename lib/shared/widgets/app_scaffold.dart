import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/shared/widgets/notification_bell_action.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.showNotificationAction = true,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final bool showNotificationAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mergedActions = <Widget>[
      if (actions != null) ...actions!,
      if (showNotificationAction) const NotificationBellAction(),
    ];

    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    
    String location = '';
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {
      // ignore and keep default
    }

    final isDashboard = location == AppRoutes.donorDashboard || location == AppRoutes.charityDashboard;
    int currentIndex = isDashboard ? 1 : 0; 

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border,
            height: 1.0,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        actions: mergedActions.isEmpty ? null : mergedActions,
      ),
      drawer: drawer,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing12),
              child: body,
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textBody,
          backgroundColor: AppColors.surface,
          onTap: (index) {
            if (index == 0) {
              context.go(AppRoutes.campaigns);
            } else if (index == 1) {
              if (user?.role == UserRole.charityOrganization) {
                context.go(AppRoutes.charityDashboard);
              } else {
                context.go(AppRoutes.donorDashboard);
              }
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Campaigns',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
          ],
        ),
      ),
    );
  }
}
