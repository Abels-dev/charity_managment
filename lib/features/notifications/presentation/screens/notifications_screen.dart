import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/notifications/presentation/providers/notification_actions_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notifications_list_provider.dart';
import 'package:charity_managment/models/app_notification.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

import 'package:charity_managment/core/widgets/empty_state.dart';
import 'package:charity_managment/core/widgets/loading_skeleton.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';

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
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.label,
          ),
          child: const Text('Mark all read'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: notificationsAsync.when(
          loading: () => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (_, index) => const SizedBox(height: 1),
            itemBuilder: (_, index) => const LoadingSkeleton(height: 80, borderRadius: 0),
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              EmptyState(
                icon: Icons.error_outline,
                title: 'Unable to load notifications',
                message: error.toString(),
              ),
            ],
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: 'No notifications yet',
                    message: 'We will notify you when updates are available.',
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationListItem(notification: notification);
              },
            );
          },
        ),
      ),
    );
  }
}

class NotificationListItem extends ConsumerWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
  });

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: () async {
        if (isUnread) {
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
        child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
          border: Border(
            left: BorderSide(
              color: isUnread ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
            bottom: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: isUnread ? AppColors.primary.withValues(alpha: 0.1) : AppColors.border.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notification.targetType),
                color: isUnread ? AppColors.primary : AppColors.textBody,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.label.copyWith(
                            color: isUnread ? AppColors.textPrimary : AppColors.textBody,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    notification.message,
                    style: AppTextStyles.body.copyWith(
                      color: isUnread ? AppColors.textPrimary : AppColors.textBody,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTextStyles.micro.copyWith(color: AppColors.textBody),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(NotificationTargetType? type) {
    if (type == null) return Icons.notifications_none;
    switch (type) {
      case NotificationTargetType.campaign:
        return Icons.campaign_outlined;
      case NotificationTargetType.donation:
        return Icons.volunteer_activism_outlined;
    }
  }

  String _formatTime(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
