import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/notifications/presentation/providers/notification_repository_provider.dart';

final notificationUnreadCountProvider = FutureProvider<int>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null) {
    return 0;
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount(user.id);
});
