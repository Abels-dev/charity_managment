import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_unread_count_provider.dart';
import 'package:charity_managment/routing/app_routes.dart';

class NotificationBellAction extends ConsumerWidget {
  const NotificationBellAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (!auth.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => context.go(AppRoutes.notifications),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: _Badge(count: unreadCount),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
