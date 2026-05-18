import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_repository_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_unread_count_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notifications_list_provider.dart';

class NotificationActionsController extends StateNotifier<AsyncValue<void>> {
  NotificationActionsController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> markAsRead(String notificationId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(notificationRepositoryProvider);
      await repository.markAsRead(notificationId);
      _ref.invalidate(notificationsListProvider);
      _ref.invalidate(notificationUnreadCountProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authControllerProvider).user;
      if (user == null) {
        throw StateError('You must be signed in.');
      }

      final repository = _ref.read(notificationRepositoryProvider);
      await repository.markAllAsRead(user.id);
      _ref.invalidate(notificationsListProvider);
      _ref.invalidate(notificationUnreadCountProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final notificationActionsProvider =
    StateNotifierProvider<NotificationActionsController, AsyncValue<void>>((ref) {
  return NotificationActionsController(ref);
});
