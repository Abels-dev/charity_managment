import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/notifications/presentation/providers/notification_actions_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notifications_list_provider.dart';
import 'package:charity_managment/features/notifications/presentation/widgets/notification_card.dart';
import 'package:charity_managment/models/app_notification.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(notificationsListProvider);
    await ref.read(notificationsListProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);
    final actionsState = ref.watch(notificationActionsProvider);

    return AppScaffold(
      title: 'Notifications',
      drawer: const AppNavigationDrawer(),
      showNotificationAction: false,
      actions: [
        TextButton(
          onPressed: actionsState.isLoading
              ? null
              : () => ref.read(notificationActionsProvider.notifier).markAllAsRead(),
          child: const Text('Mark all read'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: notificationsAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              EmptyState(
                title: 'Unable to load notifications',
                subtitle: error.toString(),
              ),
            ],
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  EmptyState(
                    title: 'No notifications yet',
                    subtitle: 'We will notify you when updates are available.',
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(notification: notification);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({
    required this.notification,
  });

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationCard(
      notification: notification,
      onTap: () async {
        if (!notification.isRead) {
          await ref.read(notificationActionsProvider.notifier).markAsRead(notification.id);
          if (!context.mounted) return;
        }

        final targetId = notification.targetId;
        final targetType = notification.targetType;
        if (targetId == null || targetType == null) return;

        switch (targetType) {
          case NotificationTargetType.campaign:
            context.go(AppRoutes.campaignDetail(targetId));
          case NotificationTargetType.donation:
            context.go(AppRoutes.donationReceipt(targetId));
        }
      },
    );
  }
}
