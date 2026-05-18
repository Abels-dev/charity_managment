import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_repository_provider.dart';
import 'package:charity_managment/models/app_notification.dart';

final notificationsListProvider = FutureProvider<List<AppNotification>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null) {
    throw StateError('You must be signed in to view notifications.');
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications(user.id);
});
